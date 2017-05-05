//
//  DevicesViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 25/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import Spring

class DevicesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 100
        self.navigationController!.navigationBar.tintColor = UIColor.white;
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        refreshControl?.addTarget(self, action: #selector(DevicesViewController.refreshDevices), for: UIControlEvents.valueChanged)

        // send push token
        let refUsers = FIRDatabase.database().reference().child("users");
        
        if(GlobalVariables.sharedInstance.user.userUID.characters.count > 0) {
            let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
            let userDefaults = UserDefaults.standard
            if let push_token = userDefaults.value(forKey: "push_token") {
                let token = ["push_token": push_token]
                userRef.updateChildValues(token)
            }
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.showLoading()
        
        let refUsers = FIRDatabase.database().reference()
        
        let userRef = refUsers.child("users").child(GlobalVariables.sharedInstance.user.userUID)
        
        // retrieve data from devices list
        userRef.observe(.value, with: { snapshot in
            if let listDevices = ((snapshot.value! as AnyObject).object(forKey: "list_devices")) {
                print("The blog post titled \(listDevices)")
                GlobalVariables.sharedInstance.user.devicesList = listDevices as! NSMutableArray
                //self.getDevices()
            } else {
                self.view.hideLoading()
            }
            
        })
        
        let timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.getDevices), userInfo: nil, repeats: false)
        
        let array : NSMutableArray = []
        let ref = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID)
        ref.queryOrderedByKey().observe(.childAdded, with: { snapshot in
            array.add(snapshot.key)
            // update devices list data on users
        })
        
        
        
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalVariables.sharedInstance.user.devicesList.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell") as! DeviceTableViewCell
        
        
        //let story = stories[indexPath.row]
        //cell.configureWithStory(story)
        
        if(GlobalVariables.sharedInstance.device.devicesList.count > 0) {
            let deviceFinal:DeviceVO = GlobalVariables.sharedInstance.device.devicesList.object(at: indexPath.row) as! DeviceVO
            
            if(deviceFinal.deviceStatus) {
                if(deviceFinal.deviceOperation == "SuperEconomy") {
                cell.configureCell(deviceFinal.deviceName, status: deviceFinal.deviceStatus.description, operation: deviceFinal.deviceOperation, statusColor: UIColor.green, operationColor: UIColor.blue)
                } else if(deviceFinal.deviceOperation == "Economy") {
                    cell.configureCell(deviceFinal.deviceName, status: deviceFinal.deviceStatus.description, operation: deviceFinal.deviceOperation, statusColor: UIColor.green, operationColor: UIColor.orange)
                } else {
                    cell.configureCell(deviceFinal.deviceName, status: deviceFinal.deviceStatus.description, operation: deviceFinal.deviceOperation, statusColor: UIColor.green, operationColor: UIColor.brown)
                }
            } else {
                if(deviceFinal.deviceOperation == "SuperEconomy") {
                    cell.configureCell(deviceFinal.deviceName, status: deviceFinal.deviceStatus.description, operation: deviceFinal.deviceOperation, statusColor: UIColor.red, operationColor: UIColor.blue)
                } else if(deviceFinal.deviceOperation == "Economy") {
                    cell.configureCell(deviceFinal.deviceName, status: deviceFinal.deviceStatus.description, operation: deviceFinal.deviceOperation, statusColor: UIColor.red, operationColor: UIColor.orange)
                } else {
                    cell.configureCell(deviceFinal.deviceName, status: deviceFinal.deviceStatus.description, operation: deviceFinal.deviceOperation, statusColor: UIColor.red, operationColor: UIColor.brown)
                }
            }
        }
        
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "devicesDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        GlobalVariables.sharedInstance.actualDevice = GlobalVariables.sharedInstance.device.devicesList.object(at: indexPath.row) as! DeviceVO
    }

    
    // MARK: - Actions
    
    func refreshDevices() {
        let refUsers = FIRDatabase.database().reference().child("users")
        
        let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
        userRef.observe(.value, with: { snapshot in
            if let listDevices = ((snapshot.value! as AnyObject).object(forKey: "list_devices")) {
                print("The blog post titled \(listDevices)")
                GlobalVariables.sharedInstance.user.devicesList = listDevices as! NSMutableArray
                self.tableView.reloadData()
                self.getDevices()
                self.refreshControl?.endRefreshing()
            } else {
                self.refreshControl?.endRefreshing()
            }
        })
        
    }
    
    func getDevices() {
        
        self.view.showLoading()
        //TODO: aqui olhar
        // aqui fazer ele pegar de devices general, porém só adicionar na lista se o UID do device for o mesmo do que da lista de devices do usuário em questão
        let ref = FIRDatabase.database().reference().child("devices_general")
        var index = 0
        GlobalVariables.sharedInstance.device.devicesList = []
        
        //ref.childByAppendingPath(GlobalVariables.sharedInstance.user.devicesList.objectAtIndex(index) as! String)
        ref.queryOrderedByValue().observe(.childAdded, with: { snapshot in
            let device:DeviceVO = DeviceVO()
            
            if let deviceName = (snapshot.value! as AnyObject).object(forKey: "device_name") as? String {
                device.deviceName = deviceName
                device.deviceUID = snapshot.key
            }
            
            if(GlobalVariables.sharedInstance.user.devicesList.contains(device.deviceUID)) {
                if let device_actived = (snapshot.value! as AnyObject).object(forKey: "device_status") as? Bool {
                    device.deviceStatus = device_actived
                }
                if let device_notification = (snapshot.value! as AnyObject).object(forKey: "device_allows_notification") as? Bool {
                    device.allowsNotification = device_notification
                }
                if let device_operation = (snapshot.value! as AnyObject).object(forKey: "device_operation") as? String {
                    device.deviceOperation = device_operation
                }
                if let device_latitude = (snapshot.value! as AnyObject).object(forKey: "device_latitude") as? Double {
                    device.latitude = device_latitude
                }
                if let device_longitude = (snapshot.value! as AnyObject).object(forKey: "device_longitude") as? Double {
                    device.longitude = device_longitude
                }
                if let device_radius = (snapshot.value! as AnyObject).object(forKey: "device_radius") as? Double {
                    device.radius = device_radius
                }
                if let device_type = (snapshot.value! as AnyObject).object(forKey: "device_atype") as? String {
                    device.deviceType = device_type
                }
                
                index = index + 1
                
                GlobalVariables.sharedInstance.device.devicesList.add(device)
                
            }
            
            
            if(GlobalVariables.sharedInstance.user.devicesList.count == index) {
                self.tableView.reloadData()
                self.view.hideLoading()
            } else if GlobalVariables.sharedInstance.user.devicesList.count == 0 {
                self.view.hideLoading()
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
