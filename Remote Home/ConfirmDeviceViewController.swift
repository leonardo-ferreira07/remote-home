//
//  ConfirmDeviceViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 25/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import Spring

class ConfirmDeviceViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var confirmDeviceView: DesignableView!
    @IBOutlet weak var nameDevice: UITextField!
    
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var registerButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameDevice.delegate = self
        
        if(GlobalVariables.sharedInstance.isChangingDeviceName) {
            titleLabel.text = ""
            subtitleLabel.text = "Mude o nome"
            nameDevice.placeholder = "Digite um novo apelido"
            registerButton.setTitle("Mudar", for: UIControlState())
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        GlobalVariables.sharedInstance.isChangingDeviceName = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func touchConfirm(_ sender: UIButton) {
        
        if(nameDevice.text!.characters.count > 1) {
            // verify if device exists first
           // save
            
            if(GlobalVariables.sharedInstance.isChangingDeviceName) {
                GlobalVariables.sharedInstance.isChangingDeviceName = false
                self.view.showLoading()
                
                var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
                var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
                var deviceName = ["device_name": nameDevice.text!]
                
                deviceRef.updateChildValues(deviceName)
                
                // duplicated code
                refDevices = FIRDatabase.database().reference().child("devices_general");
                deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
                deviceName = ["device_name": nameDevice.text!]
                
                deviceRef.updateChildValues(deviceName)
                
                
                GlobalVariables.sharedInstance.actualDevice.deviceName = nameDevice.text!
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notifyChangeInfos"), object: nil)
                self.view.hideLoading()
                self.dismiss(animated: true, completion: { () -> Void in })
                
            } else {
            
                let ref = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID)
                ref.queryOrderedByKey().observe(.childAdded, with: { snapshot in
                    print(snapshot.key)
                    if let height = snapshot.value(forKey: "height") as? Double {
                        print("\(snapshot.key) was \(height)")
                    }
                })
                
                let refUsers = FIRDatabase.database().reference().child("users");
                
                let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
                
                
                // retrieve data from devices list
                var listDevices:NSMutableArray = []
                userRef.observe(.value, with: { snapshot in
                    if(((snapshot.value! as AnyObject).object(forKey: "list_devices")) != nil) {
                        listDevices = ((snapshot.value! as AnyObject).object(forKey: "list_devices") as? NSMutableArray)!
                        print("The blog post titled \(listDevices)")
                        GlobalVariables.sharedInstance.user.devicesList = listDevices
                    }
                })
                
                var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
                
                var device = ["device_name": nameDevice.text!, "device_status": false, "device_operation": "none", "device_allows_notification": false, "device_actived": false, "device_latitude": 0.0, "device_longitude": 0.0, "device_radius": 0.0, "device_uid": GlobalVariables.sharedInstance.user.actualDeviceID] as [String : Any]
                
                refDevices.child(GlobalVariables.sharedInstance.user.actualDeviceID).setValue(device)
                
                refDevices = FIRDatabase.database().reference().child("devices_general");
                
                device = ["device_name": nameDevice.text!, "device_status": false, "device_operation": "none", "device_allows_notification": false, "device_actived": false, "device_latitude": 0.0, "device_longitude": 0.0, "device_radius": 0.0, "device_uid": GlobalVariables.sharedInstance.user.actualDeviceID]
                
                refDevices.child(GlobalVariables.sharedInstance.user.actualDeviceID).setValue(device)
                
                
                GlobalVariables.sharedInstance.user.devicesList.add(GlobalVariables.sharedInstance.user.actualDeviceID)
                GlobalVariables.sharedInstance.user.actualDeviceID = ""
                
                
                var array : NSMutableArray = []
                array = GlobalVariables.sharedInstance.user.devicesList
                let devices = ["list_devices": array]
                
                userRef.updateChildValues(devices)
                
                
                self.view.showLoading()
                self.dismiss(animated: true, completion: { () -> Void in
                    
                })
            }
        
        } else {
            confirmDeviceView.animation = "shake"
            confirmDeviceView.animate()
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // iphone 4S, precisa diminuir a distancia entre o field e o botão também
        if(UIScreen.main.bounds.height == 480) {
            topSpace.constant = 15.0
            buttonConstraint.constant = buttonConstraint.constant - 90.0;
            buttonBottomConstraint.constant = buttonBottomConstraint.constant + 90.0;
            topFieldConstraint.constant = 5.0;
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
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
