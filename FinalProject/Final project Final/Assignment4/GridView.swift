//
//  Grid.swift
//
import Foundation
import UIKit

public typealias Position = (row: Int, col: Int)
public typealias PositionSequence = [Position]



@IBDesignable class GridView: UIView {
    @IBInspectable var size: Int = 3
    @IBInspectable var livingColor : UIColor = UIColor.green
    @IBInspectable var emptyColor : UIColor = UIColor.clear
    @IBInspectable var bornColor : UIColor = UIColor.orange
    @IBInspectable var diedColor : UIColor = UIColor.red
    @IBInspectable var gridColor : UIColor = UIColor.cyan
    @IBInspectable var gridWidth : CGFloat = 2.0
    @IBInspectable var gridSize: Int = 10
    
    var gridDataSource: GridViewDataSource?
    
    func drawLine(start:CGPoint, end:CGPoint) {
        let path = UIBezierPath()
        
        path.lineWidth = 2.0
        path.move(to: start)
        path.addLine(to: end)
        gridColor.setStroke()
        path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    
    var lastTouchedPosition: Position?
    
    
    
    func convert(touch: UITouch) -> Position {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY/gridHeight * CGFloat(gridSize)
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX/gridWidth * CGFloat(gridSize)
        let position = (row: Int(row), col: Int(col))
        return position
    }
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else {return nil}
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else {return pos}
        
        if gridDataSource != nil {
            gridDataSource?[(pos.col,pos.row)] = (gridDataSource?[(pos.col,pos.row)].isAlive)! ? .empty : .alive
            setNeedsDisplay()
        }
            return pos
    }
    
    
    
    override func draw(_ rect: CGRect) {
        
        /// gridline layout
        
        
        (0 ..< gridSize).forEach {
        drawLine(
            start: CGPoint(x: CGFloat($0)/CGFloat(gridSize) * rect.size.width, y: 0.0),
            end: CGPoint(x: CGFloat($0)/CGFloat(gridSize) * rect.size.width, y: rect.size.height)
            )
        
            drawLine(
            start: CGPoint(x: 0.0, y: CGFloat($0)/CGFloat(gridSize) * rect.size.height),
            end: CGPoint(x: rect.size.width, y: CGFloat($0)/CGFloat(gridSize) * rect.size.height)
            )
        }
    
   

        let size1 = CGSize(
            width: rect.size.width/CGFloat(gridSize),
            height: rect.size.height/CGFloat(gridSize))
        let base = rect.origin
        (0 ..< gridSize).forEach { i in
            (0 ..< gridSize).forEach { j in
                
               
                let origin = CGPoint (
                    x: base.x + (CGFloat(i) * size1.width),
                    y: base.y + (CGFloat(j) * size1.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size1
                )
                
                let path = UIBezierPath(ovalIn: subRect)
                //let p = Position(i,j)
                if gridDataSource?[i,j].rawValue == "empty" {emptyColor.setFill()}
                else if gridDataSource?[i,j].rawValue == "alive" {livingColor.setFill()}
                else if gridDataSource?[i,j].rawValue == "died" {diedColor.setFill()}
                else if gridDataSource?[i,j].rawValue == "born" {bornColor.setFill()}
                path.fill()
                
            }
        }
    }
}






