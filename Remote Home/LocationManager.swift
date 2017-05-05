//
//  LocationManager.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 30/03/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


class LocationManager : NSObject, CLLocationManagerDelegate {
    
    
    var anotherLocationManager: CLLocationManager!
    var myLastLocation: CLLocationCoordinate2D!
    var myLastLocationAccuracy: CLLocationAccuracy! = 0.0
    var myLocation: CLLocationCoordinate2D!
    var myLocationAccuracy: CLLocationAccuracy! = 0.0
    var myLocationDictInPlist: [AnyHashable: Any] = [:]
    var myLocationArrayInPlist: [AnyObject] = []
    var afterResume: Bool!
    var myLocationOk:CLLocation!
    
    
    //Class method to make sure the share model is synch across the app, singleton like objc style
    class func sharedManager() -> LocationManager {
        let sharedMyModel: LocationManager? = LocationManager()
        return sharedMyModel!
    }
    
    func startMonitoringLocation() {
        if (anotherLocationManager != nil) {
            anotherLocationManager.stopMonitoringSignificantLocationChanges()
        }
        self.anotherLocationManager = CLLocationManager()
        self.anotherLocationManager.delegate = self
        self.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.anotherLocationManager.activityType = .otherNavigation
//        if IS_OS_8_OR_LATER {
            anotherLocationManager.requestAlwaysAuthorization()
//        }
        anotherLocationManager.startMonitoringSignificantLocationChanges()
    }
    
    
    func restartMonitoringLocation() {
        anotherLocationManager.stopMonitoringSignificantLocationChanges()
//        if IS_OS_8_OR_LATER {
            anotherLocationManager.requestAlwaysAuthorization()
//        }
        anotherLocationManager.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: CLLocation Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("locationManager didUpdateLocations: %@", locations)
        for i in 0 ..< locations.count {
            let newLocation: CLLocation = locations[i]
            let theLocation: CLLocationCoordinate2D = newLocation.coordinate
            let theAccuracy: CLLocationAccuracy = newLocation.horizontalAccuracy
            self.myLocation = theLocation
            self.myLocationAccuracy = theAccuracy
            self.myLocationOk = CLLocation(latitude: theLocation.latitude, longitude: theLocation.longitude)
        }
        GlobalVariables.sharedInstance.user.latitude = self.myLocation.latitude
        GlobalVariables.sharedInstance.user.longitude = self.myLocation.longitude
        self.addLocationToPList(afterResume)
    }
    
    
    // MARK: Plist helper methods
    
    // Below are 3 functions that add location and Application status to PList
    // The purpose is to collect location information locally
    
    func appState() -> String {
        let application: UIApplication = UIApplication.shared
        var appState: String = ""
        if application.applicationState == .active {
            appState = "UIApplicationStateActive"
        }
        if application.applicationState == .background {
            appState = "UIApplicationStateBackground"
        }
        if application.applicationState == .inactive {
            appState = "UIApplicationStateInactive"
        }
        return appState
    }
    
    
    func addResumeLocationToPList() {
        NSLog("addResumeLocationToPList")
        let appState: String = self.appState()
        self.myLocationDictInPlist = [AnyHashable: Any]()
        myLocationDictInPlist["Resume"] = "UIApplicationLaunchOptionsLocationKey"
        myLocationDictInPlist["AppState"] = appState
        myLocationDictInPlist["Time"] = Date()
        self.saveLocationsToPlist()
    }
    
    
    func addLocationToPList(_ fromResume: Bool) {
        NSLog("addLocationToPList")
        let appState: String = self.appState()
        self.myLocationDictInPlist = [AnyHashable: Any]()
        myLocationDictInPlist["Latitude"] = Double(self.myLocation.latitude)
        myLocationDictInPlist["Longitude"] = Double(self.myLocation.longitude)
        myLocationDictInPlist["Accuracy"] = Double(self.myLocationAccuracy)
        myLocationDictInPlist["AppState"] = appState
        if fromResume {
            myLocationDictInPlist["AddFromResume"] = "YES"
        }
        else {
            myLocationDictInPlist["AddFromResume"] = "NO"
        }
        myLocationDictInPlist["Time"] = Date()
        self.saveLocationsToPlist()
    }
    
    
    func addApplicationStatusToPList(_ applicationStatus: String) {
        NSLog("addApplicationStatusToPList")
        let appState: String = self.appState()
        self.myLocationDictInPlist = [AnyHashable: Any]()
        myLocationDictInPlist["applicationStatus"] = applicationStatus
        myLocationDictInPlist["AppState"] = appState
        myLocationDictInPlist["Time"] = Date()
        self.saveLocationsToPlist()
    }
    
    
    
    func saveLocationsToPlist() {
        let plistName: String = String(format: "LocationArray.plist")
        var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [AnyObject]
        let docDir: String = paths[0] as! String
        let fullPath: String = "\(docDir)/\(plistName)"
//        var savedProfile: NSMutableDictionary = [:]
    
        
        if var savedProfile = NSMutableDictionary(contentsOfFile: fullPath) {
            print("Determined that dictionary initialized correctly.")
            
        
            if savedProfile.count == 0 {
                savedProfile = [:]
                self.myLocationArrayInPlist = [AnyObject]()
            }
            else {
                self.myLocationArrayInPlist = savedProfile.object(forKey: "LocationArray") as! [AnyObject]
            }
            if myLocationDictInPlist.count != 0 {
                myLocationArrayInPlist.append(myLocationDictInPlist as AnyObject)
                savedProfile["LocationArray"] = myLocationArrayInPlist
            }
            if !savedProfile.write(toFile: fullPath, atomically: false) {
                NSLog("Couldn't save LocationArray.plist")
            }
            
            
            
        } else {
            var savedProfile = NSMutableDictionary(contentsOfFile: fullPath)
            if(savedProfile == nil) {
                savedProfile = [:]
            }
            if myLocationDictInPlist.count != 0 {
                myLocationArrayInPlist.append(myLocationDictInPlist as AnyObject)
                savedProfile?["LocationArray"] = myLocationArrayInPlist
            }
            if !savedProfile!.write(toFile: fullPath, atomically: false) {
                NSLog("Couldn't save LocationArray.plist")
            }
        }
        
        
        self.performActionsToServer()
        
        
        
    }
    
    
    func performActionsToServer() {
        
        let userDefaults = UserDefaults.standard
        if let uID = userDefaults.value(forKey: "uid") {
            GlobalVariables.sharedInstance.user.userUID = uID as! String
            
            
            let refUsers = FIRDatabase.database().reference().child("users");
            
            let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
            
            // retrieve data from devices list
            userRef.observe(.value, with: { snapshot in
                if let listDevices = ((snapshot.value! as AnyObject).object(forKey: "list_devices")) {
                    print("The blog post titled \(listDevices)")
                    GlobalVariables.sharedInstance.user.devicesListLocation = listDevices as! NSMutableArray
                } else {
                    
                }
                
            })
            
            
            let ref = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID)
            var index = 0
            GlobalVariables.sharedInstance.device.devicesListLocation = []
            
            //ref.childByAppendingPath(GlobalVariables.sharedInstance.user.devicesList.objectAtIndex(index) as! String)
            ref.queryOrderedByValue().observe(.childAdded, with: { snapshot in
                let device:DeviceVO = DeviceVO()
                
                if let deviceName = (snapshot.value! as AnyObject).object(forKey: "device_name") as? String {
                    device.deviceName = deviceName
                    device.deviceUID = snapshot.key
                }
                
                var deviceLocation: CLLocation!
                
                if let device_latitude = (snapshot.value! as AnyObject).object(forKey: "device_latitude") as? Double {
                    device.latitude = device_latitude
                    if let device_longitude = (snapshot.value! as AnyObject).object(forKey: "device_longitude") as? Double {
                        device.longitude = device_longitude
                        deviceLocation = CLLocation(latitude: device_latitude, longitude: device_longitude)
                    }
                }
                
                if let device_radius = (snapshot.value! as AnyObject).object(forKey: "device_radius") as? Double {
                    device.radius = device_radius
                }
                
                index = index + 1
                
                GlobalVariables.sharedInstance.device.devicesListLocation.add(device)
                
                if self.myLocationOk != nil && deviceLocation != nil {
                    if(self.myLocationOk.distance(from: deviceLocation) <= device.radius*1000) {
                        
                        
                        var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID)
                        var deviceRef = refDevices.child(device.deviceUID)
                        var deviceOperation = ["device_status": true]
                        
                        deviceRef.updateChildValues(deviceOperation)
                        
                        refDevices = FIRDatabase.database().reference().child("devices_general");
                        deviceRef = refDevices.child(device.deviceUID)
                        deviceOperation = ["device_status": true]
                        
                        deviceRef.updateChildValues(deviceOperation)
                        
                    }
                    
                    if(GlobalVariables.sharedInstance.user.devicesListLocation.count == index) {
                        // finished
                    } else if GlobalVariables.sharedInstance.user.devicesListLocation.count == 0 {
                        // none
                    }
                }
            })
            
            
            
        }
        
        
        
        
        
        
        
    }
    
    
}
