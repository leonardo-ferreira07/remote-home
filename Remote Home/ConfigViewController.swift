//
//  ConfigViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 28/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import FirebaseAuth
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ConfigViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var changePasswordTextField: UITextField!
    @IBOutlet weak var allowsNotification: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var consumptionTextField: UITextField!
    @IBOutlet weak var consumptionSaveButton: UIButton!
    @IBOutlet weak var costTextField: UITextField!
    
    
    var name:String = ""
    var password:String = ""
    var passwordFirstCharacterAfterDidBeginEditing:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        changePasswordTextField.delegate = self
        
        nameTextField.returnKeyType = .next
        changePasswordTextField.returnKeyType = .done
        
        saveButton.isEnabled = false
        
        nameTextField.text = GlobalVariables.sharedInstance.user.userName
        consumptionTextField.text = String(GlobalVariables.sharedInstance.user.maximumCost)
        costTextField.text = String(GlobalVariables.sharedInstance.user.energyCost)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == nameTextField) {
            changePasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.verifyTextField(textField)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.verifyTextField(textField)
        
        //if text is blank when first editing, then first delete is just a single space delete
        if(password.characters.count == 0 && self.passwordFirstCharacterAfterDidBeginEditing) {
            self.passwordFirstCharacterAfterDidBeginEditing = false
        }
        
        //if text is present when first editing, the first delete will result in clearing the entire password, even after typing text
        if(password.characters.count > 0 && self.passwordFirstCharacterAfterDidBeginEditing && string.characters.count == 0 && textField == self.changePasswordTextField)
        {
            NSLog("Deleting all characters")
            self.passwordFirstCharacterAfterDidBeginEditing = false
        }
        
        return true
    }
    
    func verifyTextField(_ textField: UITextField) -> Void {
        if(textField == nameTextField) {
            self.name = textField.text!
        } else {
            self.password = textField.text!
        }
        
        if(name.characters.count-1 > 0) { // adicionar verificação para ver se o valor inserido é diferente do valor anterior
            saveButton.isEnabled = true
        } else if(name.characters.count-1 <= 0 || password.characters.count-1 <= 0){
            saveButton.isEnabled = false
        }
        
        
    }

    // MARK: - Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func changeNotification(_ sender: UISwitch) {
        
    }
    
    
    @IBAction func clickedSaveConsumption(_ sender: AnyObject) {
        
        if(self.consumptionTextField.text?.characters.count > 0) {
            let refUsers = FIRDatabase.database().reference().child("users");
            
            self.view.showLoading()
            
            let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
            let consumption = ["maximum_cost": Double(self.consumptionTextField.text!.replacingOccurrences(of: ",", with: "."))!]
            GlobalVariables.sharedInstance.user.maximumCost = Double(self.consumptionTextField.text!.replacingOccurrences(of: ",", with: "."))!
            
            userRef.updateChildValues(consumption)
            self.view.hideLoading()
        }
        
    }
    
    
    @IBAction func clickedSaveCost(_ sender: AnyObject) {
        if(self.costTextField.text?.characters.count > 0) {
            let refUsers = FIRDatabase.database().reference().child("users");
            
            self.view.showLoading()
            
            let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
            let cost = ["energy_cost": Double(self.costTextField.text!.replacingOccurrences(of: ",", with: "."))!]
            GlobalVariables.sharedInstance.user.energyCost = Double(self.costTextField.text!.replacingOccurrences(of: ",", with: "."))!
            
            userRef.updateChildValues(cost)
            self.view.hideLoading()
        }
    }

    
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        
        let refUsers = FIRDatabase.database().reference().child("users");
        
        self.view.showLoading()
        
        if(GlobalVariables.sharedInstance.user.userName != self.nameTextField.text!) {
            
            let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
            let name = ["full_name": self.nameTextField.text!]
            GlobalVariables.sharedInstance.user.userName = self.nameTextField.text!
            
            userRef.updateChildValues(name)
            self.view.hideLoading()
        }
        
//        var newPasswordField: UITextField?
//        
//        func passwordEntered(alert: UIAlertAction!){
//            let user = FIRAuth.auth()?.currentUser
//            
//            user?.updatePassword(newPasswordField!.text!) { error in
//                if error != nil {
//                    // An error happened.
//                } else {
//                    // Password updated.
//                    self.changePasswordTextField.text = nil
//                    self.view.hideLoading()
//                }
//            }
//        }
//        func addTextField(textField: UITextField!){
//            textField.placeholder = "Nova senha"
//            textField.secureTextEntry = true
//            newPasswordField = textField
//        }
//        
//        // display an alert
//        let newWordPrompt = UIAlertController(title: "Nova senha", message: "Insira sua nova senha para continuar", preferredStyle: UIAlertControllerStyle.Alert)
//        newWordPrompt.addTextFieldWithConfigurationHandler(addTextField)
//        newWordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
//        newWordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: passwordEntered))
//        presentViewController(newWordPrompt, animated: true, completion: nil)
        
        
        
    }
    
    
    @IBAction func clickedLogout(_ sender: UIButton) {
        // send logot to server
        // clear singleton
        GlobalVariables.sharedInstance.user = UserVO()
        GlobalVariables.sharedInstance.device = DeviceVO()
        GlobalVariables.sharedInstance.actualDevice = DeviceVO()
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(nil, forKey: "password")
        userDefaults.setValue(nil, forKey: "mail")
        userDefaults.setValue(nil, forKey: "uid")
        userDefaults.synchronize()
        
        self.view.showLoading()
        self.performSegue(withIdentifier: "Logout", sender: nil)
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
