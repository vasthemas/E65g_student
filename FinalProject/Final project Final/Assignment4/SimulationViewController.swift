//
//  FirstViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

import Foundation

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //let aVariable = appDelegate.someVariable
    
    @IBOutlet weak var gridView: GridView!
    var engine: StandardEngine!
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        engine = StandardEngine.engine
        gridView.gridSize = engine.rows
        gridView.gridDataSource = self
        engine.delagate = self
        
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        engine.grid = self.engine.step()
        
    }
    @IBAction func didResetGrid(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey1), object: self)
        
        for i in 0 ... StandardEngine.engine.rows {
            for j in 0 ... StandardEngine.engine.cols {
                StandardEngine.engine.grid[i,j] = .empty
        StandardEngine.engine.notifyDelageandPublishGrid()
                
        
            
        }
    }
        
    }
    
    @IBAction func didSaveState(_ sender: Any) {
        
        
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SaveSimuNotification"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: self)

    
        
        
    }
    
        
 
    

}

