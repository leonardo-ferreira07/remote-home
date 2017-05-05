//
//  LoginViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 22/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonView: UIView!
    
    @IBOutlet weak var constraintBetween: NSLayoutConstraint!
    var mail:String = ""
    var password:String = ""
    var passwordFirstCharacterAfterDidBeginEditing:Bool = false
    var uid:String = ""
    
    // Create a reference to a Firebase location
    var myRootRef = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.mailTextField.returnKeyType = UIReturnKeyType.next
        self.mailTextField.keyboardType = UIKeyboardType.emailAddress
        self.passwordTextField.returnKeyType = UIReturnKeyType.done
        
        loginButtonView.alpha = 0.0
        constraintBetween.constant = -40.0
        
        self.mailTextField.text = "leo@leo.com"
        self.passwordTextField.text = "12345678"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Actions
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        
        mail = mailTextField.text!
        password = passwordTextField.text!
        
        view.showLoading()
        
        
        FIRAuth.auth()?.signIn(withEmail: mail, password: password) { (user, error) in
                            
                            if error != nil {
                                self.view.hideLoading()
                                // There was an error logging in to this account
                            } else {
                                // We are now logged in
                                self.uid = user!.uid
                                GlobalVariables.sharedInstance.user.userUID = self.uid
                                GlobalVariables.sharedInstance.user.userEmail = self.mail

                                let userDefaults = UserDefaults.standard
                                userDefaults.setValue(self.password, forKey: "password")
                                userDefaults.setValue(GlobalVariables.sharedInstance.user.userEmail, forKey: "mail")
                                userDefaults.setValue(self.uid, forKey: "uid")
                                userDefaults.synchronize()
                                
                                self.retrieveDataFromUser()
                                self.performSegue(withIdentifier: "devices", sender: nil)
                            }
        }

    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        
        
    }

    
    
    // MARK: UITextFieldDelegate
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == mailTextField) {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.verifyTextField(textField)
        if(textField == self.passwordTextField)
        {
            self.passwordFirstCharacterAfterDidBeginEditing = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.verifyTextField(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.verifyTextField(textField)
        
        //if text is blank when first editing, then first delete is just a single space delete
        if(password.characters.count == 0 && self.passwordFirstCharacterAfterDidBeginEditing) {
            self.passwordFirstCharacterAfterDidBeginEditing = false
        }
        
        //if text is present when first editing, the first delete will result in clearing the entire password, even after typing text
        if(password.characters.count > 0 && self.passwordFirstCharacterAfterDidBeginEditing && string.characters.count == 0 && textField == self.passwordTextField)
        {
            NSLog("Deleting all characters")
            self.constraintBetween.constant = -40.0
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.loginButtonView.alpha = 0.0
                            
            })
            self.passwordFirstCharacterAfterDidBeginEditing = false
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.verifyTextField(textField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.verifyTextField(textField)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.verifyTextField(textField)
        return true
    }
    
    func verifyTextField(_ textField: UITextField) -> Void {
        if(textField == mailTextField) {
            self.mail = textField.text!
        } else {
            self.password = textField.text!
        }
        
        if(textField == mailTextField) {
            if (!self.mail.contains("@") || !self.mail.contains(".")){
                textField.textColor = UIColor.red
            } else {
                textField.textColor = UIColor.black
            }
        }
        
        if(mail.characters.count-1 > 0 && password.characters.count-1 > 0 && (mail.contains("@") && mail.contains(".")) ) {
            self.constraintBetween.constant = 40.0
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.loginButtonView.alpha = 1.0
                
            })
        } else if(mail.characters.count-1 <= 0 || password.characters.count-1 <= 0){
            self.constraintBetween.constant = -40.0
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.loginButtonView.alpha = 0.0
                
            })
        }
        
        
    }

    
    func retrieveDataFromUser() {
        // Create a reference to a Firebase location
        let ref = FIRDatabase.database().reference().child("users").child(self.uid)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
