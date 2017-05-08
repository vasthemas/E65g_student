//
//  Grid.swift
//
import Foundation
public typealias GridPosition = (row: Int, col: Int)
public typealias GridSize = (rows: Int, cols: Int)

fileprivate func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

public protocol GridViewDataSource {
    subscript (row: Int, col: Int) -> CellState { get set }
}

public protocol GridProtocol {
    init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState)
    var description: String { get }
    var size: GridSize { get }
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self 
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition($0) }
}
public enum CellState : String {
    case alive  = "alive"
    case empty = "empty"
    case born = "born"
    case died = "died"
    
    func description() -> String {
        switch self {
        case .alive: return self.rawValue
        case .born : return self.rawValue
        case.died : return self.rawValue
        case .empty : return self.rawValue
        }
    }
    func toggle(value:CellState) -> CellState {
        switch value {
        case .alive, .born:
            return .empty
        case .died, .empty:
            return .alive
        }
    }
    
    static var allValues: [CellState] {
        return [alive, empty, born, died]
    }
    
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
}


let offsets: [GridPosition] = [
    (row: -1, col:  -1), (row: -1, col:  0), (row: -1, col:  1),
    (row:  0, col:  -1),                     (row:  0, col:  1),
    (row:  1, col:  -1), (row:  1, col:  0), (row:  1, col:  1)
]

extension GridProtocol {
   }

public struct Grid: GridProtocol, GridViewDataSource {
    private var _cells: [[CellState]]
    public let size: GridSize

    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState = { _, _ in .empty }) {
        _cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: rows)), count: cols))
        size = GridSize(rows, cols)
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Grid {
        var nextGrid = Grid(size.rows, size.cols) { _, _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

extension Grid: Sequence {
    fileprivate var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive   }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: GridProtocol
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> GridProtocol? {
            if history.hasCycle { return nil }
            let newGrid:Grid = grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case (0, 1), (1, 2), (2, 0), (2, 1), (2, 2): return .alive
        default: return .empty
        }
    }
}

protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delagate: EngineDelegate? {get set}
    var grid: GridProtocol {get}
    var refreshRate: Timer? {get set}
    var refreshTimer: Double {get set}
    var rows: Int {get set}
    var cols: Int {get set}
    var updateClosure: ((Grid) -> Void)? { get set }
    init(rows: Int, cols: Int)
    func step() -> GridProtocol
    
}


class StandardEngine : EngineProtocol {
    var refreshRate: Timer?
    
    var refreshTimer: Double = 0.0 {
        
        didSet {
            if refreshTimer > 0.0 {
                if #available(iOS 10.0, *) {
                    refreshRate = Timer.scheduledTimer(
                        withTimeInterval: refreshTimer,
                        repeats: true
                    ) { (t: Timer) in
                        _ = self.step()
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            else {
                refreshRate?.invalidate()
                refreshRate = nil
            }
        }
    }


    var grid: GridProtocol
    
    var updateClosure: ((Grid) -> Void)?

    var delagate: EngineDelegate?
    
    var rows: Int = 0
    
    var cols: Int = 0
    
    static var engine: StandardEngine = StandardEngine(rows: 10,cols: 10) {
        didSet {
            if engine.rows != oldValue.rows {
                
                StandardEngine.engine.rows = engine.rows
                StandardEngine.engine.cols = engine.rows
                
            }
            
        }
        
    }
    
    required init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.grid = Grid(rows, cols, cellInitializer: {_,_ in .empty})
        self.notifyDelageandPublishGrid()
        delagate?.engineDidUpdate(withGrid: self.grid)
        
    }
    
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
        self.notifyDelageandPublishGrid()
        return grid
    }
    
    func changeEngineSize(size: Int) -> (){
        StandardEngine.engine.rows = size
        StandardEngine.engine.cols = size
        self.notifyDelageandPublishGrid()
        return StandardEngine.engine = StandardEngine(rows: size, cols: size)
        
    }
    
    func notifyDelageandPublishGrid() {
        self.delagate?.engineDidUpdate(withGrid:  self.grid)
        //let nc = NotificationCenter.default
        //let name = Notification.Name(rawValue: "EngineUpdate")
       // let n = Notification(name: name, object: nil, userInfo: ["engine" : self])
        //nc.post(n)
    
    }
    
    func changeIntialEngineGrid(GridData: [Array<Any>]) -> () {
        
        
        var list1 = [Int]()
        print(GridData)
        for i in GridData {
        
            let z = ((i as AnyObject)[0])
            let h = ((i as AnyObject)[1])
            list1.append(z as! Int)
            list1.append(h as! Int)
        }
        if list1.count == 0 {
            list1.append(10)
        }
        let size1 = list1.max()!
        
        StandardEngine.engine = StandardEngine(rows: size1 + 1, cols: size1 + 1)
        
        self.notifyDelageandPublishGrid()
        
        for i in GridData {
            let y = ((i as AnyObject)[0])
            let x = ((i as AnyObject)[1])
            
            StandardEngine.engine.grid[x as! Int,y as! Int] = .alive
            self.notifyDelageandPublishGrid()
            
            
        }

        
    }
    func getStateOfEngine() -> [String:[[Any]]] {
        var statOfGame = [
            "alive" : [[]],
            "born" : [[]],
            "died" : [[]]
        ]
        
        var alive = [[Any]]()
        var born = [[Any]]()
        var died = [[Any]]()
        
        for i in 0 ... StandardEngine.engine.rows {
            for j in 0 ... StandardEngine.engine.cols {
                if StandardEngine.engine.grid[j,i] == .alive {
                    alive.append([j,i])
                    
                }
                if StandardEngine.engine.grid[j,i] == .born {
                    born.append([j,i])
                    
                }
                if StandardEngine.engine.grid[j,i] == .born {
                    born.append([j,i])
                
                }
                if StandardEngine.engine.grid[j,i] == .died {
                    died.append([j,i])
                
               }
            }
        }
            
       statOfGame["alive"] = alive
        
       return statOfGame
    }

   
}





