//
//  InitialViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 12/04/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class InitialViewController: UIViewController {
    
    var fail = false
    var passei = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let userDefaults = UserDefaults.standard
        if let password = userDefaults.value(forKey: "password") {
            if let mail = userDefaults.value(forKey: "mail") {
                let email:String = mail as! String
                let pass:String = password as! String
                FIRAuth.auth()?.signIn(withEmail: email, password: pass) { (user, error) in
                                    self.passei = true
                                    
                                    if error != nil {
                                        self.fail = true
                                    } else {
                                        // We are now logged in
                                        GlobalVariables.sharedInstance.user.userUID = user!.uid
                                        GlobalVariables.sharedInstance.user.userEmail = mail as! String
                                        
                                        self.retrieveDataFromUser()
                                        self.changeScreen()
                                    }
                                    
                                    
                }
            } else {
                
                self.fail = true
            }
        } else {
            self.fail = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        passei = true
        self.changeScreen()
        
        
    }
    
    
    func retrieveDataFromUser() {
        // Create a reference to a Firebase location
        let ref = FIRDatabase.database().reference().child("users").child(GlobalVariables.sharedInstance.user.userUID)
        ref.queryOrderedByKey().observe(.value, with: { snapshot in
            if let lala = snapshot.value as? NSDictionary {
                
                if let name = lala.value(forKey: "full_name") as? String {
                    print("\(snapshot.key) was \(name)")
                    GlobalVariables.sharedInstance.user.userName = name
                }
                if let consumption = lala.value(forKey: "maximum_cost") as? Double {
                    print("\(snapshot.key) was \(consumption)")
                    GlobalVariables.sharedInstance.user.maximumCost = consumption
                }
                if let cost = lala.value(forKey: "energy_cost") as? Double {
                    print("\(snapshot.key) was \(cost)")
                    GlobalVariables.sharedInstance.user.energyCost = cost
                }
                if let cellPhone = lala.value(forKey: "cellphone") as? String {
                    print("\(snapshot.key) was \(cellPhone)")
                    GlobalVariables.sharedInstance.user.userPhone = cellPhone
                }
            }
            
        })
    }
    
    func changeScreen() {
        if fail != true && passei {
            self.performSegue(withIdentifier: "autoLoginSuccess", sender: nil)
        } else if passei {
            self.performSegue(withIdentifier: "autoLoginFail", sender: nil)
        }
    }
    

}
