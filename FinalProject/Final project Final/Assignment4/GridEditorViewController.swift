//
//  GridEditor.swift
//  Assignment4
//
//  Created by Wyss User on 4/30/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit




class GridEditorViewController: UIViewController  {

    @IBOutlet weak var gridEditorView: GridView!
    @IBOutlet weak var gridNameTextField: UITextField!
    var gridName: String?
    var contentGrid = NSArray()
    var saveClosure: ((String) -> Void)?
    var saveGridClosure: (([Array<Any>]) -> Void)?
    var engine: StandardEngine!
    
    
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        print("loading.....")
        print(type(of: contentGrid))
        print(contentGrid.count)
        print(contentGrid)
        
        
         // Do any additional setup after loading the view.
        super.viewDidLoad()
        var list1 = [Int]()
        
        
    
        
        
        for i in contentGrid {
            let z = ((i as AnyObject)[0])
            let h = ((i as AnyObject)[1])
            list1.append(z as! Int)
            list1.append(h as! Int)
        }
        if list1.count == 0 {
            list1.append(10)
        }
        let size1 = list1.max()!
        
        var editGrid = Grid(size1 + 1,size1 + 1)
        gridEditorView.gridSize = editGrid.size.rows
        
        if contentGrid.count > 1 {
            for i in contentGrid {
                let y = ((i as AnyObject)[0])
                let x = ((i as AnyObject)[1])
            
                editGrid[x as! Int,y as! Int] = .alive
                
            }
        }
        
            

        
        gridEditorView.gridDataSource = editGrid
        navigationController?.isNavigationBarHidden = false
        if let gridName = gridName {
        gridNameTextField.text = gridName
            
       
            
        }
    }
    
    
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func save(_ sender: Any) {
        
        var newContentGrid = [Array<Any>]()
        for i in 0 ... gridEditorView.gridSize {
            for j in 0 ... gridEditorView.gridSize {
                
                if gridEditorView.gridDataSource?[i,j].isAlive == true {
                    newContentGrid.append([j,i])
                    
                }
            }
            
        }
        print(newContentGrid)
        StandardEngine.engine.changeIntialEngineGrid(GridData: newContentGrid)

     
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            
        }

         let newGridValue = newContentGrid
            do {self.saveGridClosure!(newGridValue)
        
        }
        
            _ = self.navigationController?.popViewController(animated: true)
        }
    
    @IBAction func cancelGridEdit(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    overrivarfunc prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
