//
//  FiltersViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 08/09/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var initialDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialDate.timeZone = TimeZone(abbreviation: "BRT")
        self.endDate.timeZone = TimeZone(abbreviation: "BRT")

        // Do any additional setup after loading the view.
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func saveFilter(_ sender: UIBarButtonItem) {
        GlobalVariables.sharedInstance.initialDate = initialDate.date
        GlobalVariables.sharedInstance.endDate = endDate.date
        GlobalVariables.sharedInstance.shouldReloadGraphics = true
        print(initialDate.date)
        print(endDate.date)
        self.navigationController?.popViewController(animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
