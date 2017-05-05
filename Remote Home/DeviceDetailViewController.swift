//
//  DeviceDetailViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 27/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController {

    
    @IBOutlet weak var deviceStateLabel: UILabel!
    @IBOutlet weak var deviceStateView: UIView!
    @IBOutlet weak var descriptionOperation: UILabel!
    
    @IBOutlet weak var activateDeactivateDevice: UISwitch!
    @IBOutlet weak var activateNotification: UISwitch!
    
    @IBOutlet weak var operationModeControl: UISegmentedControl!
    
    @IBOutlet weak var deviceNameButton: UIButton!
    
    @IBOutlet weak var deviceTypeSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        updateDeviceInfos()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DeviceDetailViewController.updateDeviceInfos),
            name: NSNotification.Name(rawValue: "notifyChangeInfos"),
            object: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notifyChangeInfos"), object: nil)
    }
    

    // MARK: - Actions
    
    @IBAction func changeDeviceType(_ sender: UISegmentedControl) {
        var stringType = ""
        if(sender.selectedSegmentIndex == 0) {
            stringType = "cafeteira"
        } else if(sender.selectedSegmentIndex == 1) {
            stringType = "televisao"
        } else {
            stringType = "none"
        }
        var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
        var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        var deviceOperation = ["device_atype": stringType]
        
        deviceRef.updateChildValues(deviceOperation)
        
        refDevices = FIRDatabase.database().reference().child("devices_general");
        deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        deviceOperation = ["device_atype": stringType]
        
        deviceRef.updateChildValues(deviceOperation)
        
        GlobalVariables.sharedInstance.actualDevice.deviceType = stringType
        updateDeviceInfos()
    }
    
    
    @IBAction func changeDeviceState(_ sender: UISwitch) {
        
        var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
        var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        var deviceActivate = ["device_status": activateDeactivateDevice.isOn]
        
        deviceRef.updateChildValues(deviceActivate)
        
        refDevices = FIRDatabase.database().reference().child("devices_general");
        deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        deviceActivate = ["device_status": activateDeactivateDevice.isOn]
        
        deviceRef.updateChildValues(deviceActivate)
        
        
        GlobalVariables.sharedInstance.actualDevice.deviceStatus = activateDeactivateDevice.isOn
        updateDeviceInfos()
        
    }
    
    @IBAction func changeDeviceOperation(_ sender: UISegmentedControl) {
        var stringOp = ""
        if(sender.selectedSegmentIndex == 0) {
            descriptionOperation.text = "O modo super econômico prevê maior economia para seu sistema, com desligamentos programados, mais cedo."
            stringOp = "SuperEconomy"
        } else if(sender.selectedSegmentIndex == 1) {
            descriptionOperation.text = "O modo econômico prevê economia de energia com produtividade, com desligamentos programados."
            stringOp = "Economy"
        } else {
            descriptionOperation.text = "O modo normal faz um desligamento tardio do seu dispositivo conectado ao sistema."
            stringOp = "Normal"
        }
        
        var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
        var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        var deviceOperation = ["device_operation": stringOp]
        
        deviceRef.updateChildValues(deviceOperation)
        
        refDevices = FIRDatabase.database().reference().child("devices_general");
        deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        deviceOperation = ["device_operation": stringOp]
        
        deviceRef.updateChildValues(deviceOperation)
        
        GlobalVariables.sharedInstance.actualDevice.deviceOperation = stringOp
        updateDeviceInfos()
        
    }
    
    
    @IBAction func changeDeviceName(_ sender: UIButton) {
        GlobalVariables.sharedInstance.isChangingDeviceName = true
        self.tabBarController!.performSegue(withIdentifier: "confirmDevice", sender: nil)
    }
    
   
    @IBAction func changeNotification(_ sender: UISwitch) {
        var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
        var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        var deviceNotification = ["device_allows_notification": activateNotification.isOn]
        
        deviceRef.updateChildValues(deviceNotification)
        
        
        refDevices = FIRDatabase.database().reference().child("devices_general");
        deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        deviceNotification = ["device_allows_notification": activateNotification.isOn]
        
        deviceRef.updateChildValues(deviceNotification)
        
        
        GlobalVariables.sharedInstance.actualDevice.allowsNotification = activateNotification.isOn
        updateDeviceInfos()
    }
    
    
    func updateDeviceInfos() {
        
        if(GlobalVariables.sharedInstance.actualDevice.deviceName.characters.count > 0) {
            deviceNameButton.setTitle(GlobalVariables.sharedInstance.actualDevice.deviceName, for:UIControlState())
        }
        
        if(GlobalVariables.sharedInstance.actualDevice.deviceOperation.characters.count > 0) {
            if(GlobalVariables.sharedInstance.actualDevice.deviceOperation == "SuperEconomy") {
                operationModeControl.selectedSegmentIndex = 0
            } else if(GlobalVariables.sharedInstance.actualDevice.deviceOperation == "Economy") {
                operationModeControl.selectedSegmentIndex = 1
            } else {
                operationModeControl.selectedSegmentIndex = 2
            }
        }
        
        if(operationModeControl.selectedSegmentIndex == 0) {
            descriptionOperation.text = "O modo super econômico prevê maior economia para seu sistema, com desligamentos programados, mais cedo."
        } else if(operationModeControl.selectedSegmentIndex == 1) {
            descriptionOperation.text = "O modo econômico prevê economia de energia com produtividade, com desligamentos programados."
        } else {
            descriptionOperation.text = "O modo normal faz um desligamento tardio do seu dispositivo conectado ao sistema."
        }
        
        if(GlobalVariables.sharedInstance.actualDevice.deviceType.characters.count > 0) {
            if(GlobalVariables.sharedInstance.actualDevice.deviceType == "cafeteira") {
                deviceTypeSegmented.selectedSegmentIndex = 0
            } else if(GlobalVariables.sharedInstance.actualDevice.deviceType == "televisao") {
                deviceTypeSegmented.selectedSegmentIndex = 1
            } else {
                deviceTypeSegmented.selectedSegmentIndex = 2
            }
        }
        
        if(GlobalVariables.sharedInstance.actualDevice.deviceStatus) {
            activateDeactivateDevice.setOn(true, animated: true)
            self.deviceStateLabel.text = "Ativado"
        } else {
            activateDeactivateDevice.setOn(false, animated: true)
            self.deviceStateLabel.text = "Desativado"
        }
        
        if(GlobalVariables.sharedInstance.actualDevice.deviceStatus) {
            self.deviceStateView.backgroundColor = UIColor.green
        } else {
            self.deviceStateView.backgroundColor = UIColor.red
        }
        
        if(GlobalVariables.sharedInstance.actualDevice.allowsNotification) {
            activateNotification.setOn(true, animated: true)
        } else {
            activateNotification.setOn(false, animated: true)
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
