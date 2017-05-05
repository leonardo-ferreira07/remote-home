//
//  CreateMyAccountViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 22/02/16.
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CreateMyAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var criarButton: UIBarButtonItem!
    
    @IBOutlet weak var backView: UIView!
    
    var passwordFirstCharacterAfterDidBeginEditing:Bool = false
    var password:String = ""
    var mail:String = ""
    var name:String = ""
    var phone:String = ""
    var uid:String = ""
    
    // Create a reference to a Firebase location
    var myRootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        criarButton.setTitleTextAttributes([NSFontAttributeName:UIFont.boldSystemFont(ofSize: 17)], for: UIControlState())
        criarButton.isEnabled = false
        
        passwordTextField.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        
        phoneTextField.keyboardType = UIKeyboardType.decimalPad
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        nameTextField.returnKeyType = UIReturnKeyType.next
        emailTextField.returnKeyType = UIReturnKeyType.next
        phoneTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.done
        
        scrollView.keyboardDismissMode = .onDrag

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backView.endEditing(true)
    }
    
    // MARK - Actions
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.scrollView.endEditing(true)
    }
    
    
    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    @IBAction func createButtonPressed(_ sender: UIBarButtonItem) {
        
        view.showLoading()
        
        if(self.passwordTextField.text?.characters.count >= 6) {
        
            FIRAuth.auth()?.createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error != nil {
                    // There was an error creating the account
                } else {
                    self.uid = (user!.uid as String)
                    print("Successfully created user account with uid: \(self.uid)")
                    self.createUserInfos()
                    self.logUser()
                }
            }
        } else {
            let alert = UIAlertView(title: "Erro", message: "Sua senha deve conter pelo menos 6 caracteres", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            view.hideLoading()
        }
        
        
    }
    
    
    func logUser () {
        FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                        
                        if error != nil {
                            // There was an error logging in to this account
                        } else {
                            // We are now logged in
                            self.performSegue(withIdentifier: "devices", sender: nil)
                        }
        }
    }
    
    func createUserInfos () {
        let alanisawesome = ["full_name": self.nameTextField.text!, "cellphone": self.phoneTextField.text!]
        
        let usersRef = myRootRef.child("users")
        
        GlobalVariables.sharedInstance.user.userEmail = self.emailTextField.text!
        GlobalVariables.sharedInstance.user.userUID = self.uid
        GlobalVariables.sharedInstance.user.userPhone = self.phoneTextField.text!
        GlobalVariables.sharedInstance.user.userName = self.nameTextField.text!
        
        print(GlobalVariables.sharedInstance.user.userEmail)
        
        usersRef.child(self.uid).setValue(alanisawesome)
    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(UIScreen.main.bounds.height < 667) {
            var point:CGPoint = textField.bounds.origin
            point.y = point.y+15
            if(textField == passwordTextField) {
                point.y += 40
            }
        
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.scrollView.contentOffset = point
            }) 
        }
        
        self.verifyTextField(textField)
        
        if(textField == self.passwordTextField)
        {
            self.passwordFirstCharacterAfterDidBeginEditing = true
        }
        
    }
    
    // MARK: UITextFieldDelegate
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == nameTextField) {
            emailTextField.becomeFirstResponder()
        } else if(textField == emailTextField) {
            phoneTextField.becomeFirstResponder()
        } else if(textField == phoneTextField) {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.verifyTextField(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.verifyTextField(textField)
        
        //if text is blank when first editing, then first delete is just a single space delete
        if(passwordTextField.text!.characters.count == 0 && self.passwordFirstCharacterAfterDidBeginEditing) {
            self.passwordFirstCharacterAfterDidBeginEditing = false
        }
        
        //if text is present when first editing, the first delete will result in clearing the entire password, even after typing text
        if(passwordTextField.text!.characters.count > 0 && self.passwordFirstCharacterAfterDidBeginEditing && string.characters.count == 0 && textField == self.passwordTextField)
        {
            NSLog("Deleting all characters")
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.criarButton.isEnabled = false
                
            })
            self.passwordFirstCharacterAfterDidBeginEditing = false
        }
        
        print(textField.text)
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
        if(textField == emailTextField) {
            self.mail = textField.text!
        } else if(textField == nameTextField) {
            self.name = textField.text!
        } else if(textField == phoneTextField) {
            self.phone = textField.text!
        } else {
            self.password = textField.text!
        }
        
        if(textField == emailTextField) {
            if (!self.mail.contains("@") || !self.mail.contains(".")){
                textField.textColor = UIColor.red
            } else {
                textField.textColor = UIColor.black
            }
        }
        
        if(mail.characters.count-1 > 0 && password.characters.count-1 > 0 && (mail.contains("@") && mail.contains(".")) && name.characters.count-1 > 0 && phone.characters.count-1 > 0) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.criarButton.isEnabled = true
                
            })
        } else if(mail.characters.count-1 <= 0 || password.characters.count-1 <= 0 || name.characters.count-1 <= 0 || phone.characters.count-1 <= 0){
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.criarButton.isEnabled = false
                
            })
        }
        
        
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
