//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Wyss User on 5/8/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

 let mySpecialNotificationKey1 = "specialNotificationKey1"

class StatisticsViewController: UIViewController {
    @IBOutlet weak var aliveCountField: UITextField!
    
    @IBOutlet weak var deadCountField: UITextField!
    
    @IBOutlet weak var bornCountField: UITextField!
    
    
    
    
    
    var engine: StandardEngine!
    
   
    
    var aliveCount = 0
    
    var diedCount = 0
    
    var bornCount = 0
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func resetCount() {
        aliveCount = 0
        
        diedCount = 0
        
        bornCount = 0
        

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatisticsViewController.resetCount), name: NSNotification.Name(rawValue: mySpecialNotificationKey1), object: nil)
        
        
        self.resetCount()
        for i in 0 ... StandardEngine.engine.rows {
            for j in 0 ... StandardEngine.engine.cols {
                if StandardEngine.engine.grid[i,j] == .alive {
                    aliveCount = aliveCount + 1
                    
                }
                if StandardEngine.engine.grid[i,j] == .died {
                    diedCount = diedCount + 1
                    
                }
                if StandardEngine.engine.grid[i,j] == .born {
                    bornCount = bornCount + 1
                    
                }
                
        
    }
        }
        
        aliveCountField.text = "\(aliveCount)"
        deadCountField.text = "\(diedCount)"
        bornCountField.text =  "\(bornCount)"
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
