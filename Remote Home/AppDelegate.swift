//
//  AppDelegate.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 22/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shareModel: LocationManager!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Register for remote notifications
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        UITabBar.appearance().tintColor = UIColor(red: 44/255.0, green: 99/255.0, blue: 210/255.0, alpha: 1.0)
        
        FIRApp.configure()
        
        NSLog("didFinishLaunchingWithOptions")
        self.shareModel = LocationManager.sharedManager()
        self.shareModel.afterResume = false
        self.shareModel.addApplicationStatusToPList("didFinishLaunchingWithOptions")
        
        
        var alert: UIAlertView
        //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
        if UIApplication.shared.backgroundRefreshStatus == UIBackgroundRefreshStatus.denied {
            alert = UIAlertView(title: "", message: "The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
            alert.show()
        }
        else if UIApplication.shared.backgroundRefreshStatus == UIBackgroundRefreshStatus.restricted {
            alert = UIAlertView(title: "", message: "The functions of this app are limited because the Background App Refresh is disable.", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
            alert.show()
        } else {
            // When there is a significant changes of the location,
            // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
            // When the app is receiving the key, it must reinitiate the locationManager and get
            // the latest location updates
            // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
            // the app has been killed/terminated (Not in th background) by iOS or the user.
            //if let options = launchOptions {
                //NSLog("UIApplicationLaunchOptionsLocationKey : %@", (options[UIApplicationLaunchOptionsLocationKey] as! String))
                if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
                    // This "afterResume" flag is just to show that he receiving location updates
                    // are actually from the key "UIApplicationLaunchOptionsLocationKey"
                    self.shareModel.afterResume = true
                    self.shareModel.startMonitoringLocation()
                    self.shareModel.addResumeLocationToPList()
                }
           // }
            
            
            
            if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
                print("It's a location event")
            }
        }
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                                         name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NSLog("applicationDidEnterBackground")
        self.shareModel.restartMonitoringLocation()
        self.shareModel.addApplicationStatusToPList("applicationDidEnterBackground")
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        NSLog("applicationDidBecomeActive")
        self.shareModel.addApplicationStatusToPList("applicationDidBecomeActive")
        //Remove the "afterResume" Flag after the app is active again.
        self.shareModel.afterResume = false
        self.shareModel.startMonitoringLocation()
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        
        NSLog("applicationWillTerminate")
        self.shareModel.addApplicationStatusToPList("applicationWillTerminate")
        
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Kaminski-Ferreira.Remote_Home" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Remote_Home", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    
    // MARK: Push Notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
//        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(refreshedToken, forKey: "push_token")
            userDefaults.synchronize()
            
            // send push token
            if(GlobalVariables.sharedInstance.user.userUID.characters.count > 0) {
                let refUsers = FIRDatabase.database().reference().child("users");
                let userRef = refUsers.child(GlobalVariables.sharedInstance.user.userUID)
                let userDefaults = UserDefaults.standard
                if let push_token = userDefaults.value(forKey: "push_token") {
                    let token = ["push_token": push_token]
                    userRef.updateChildValues(token)
                }
                
            }
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let characterSet: CharacterSet = CharacterSet(charactersIn: "<>")
        
        let deviceTokenString: String = (deviceToken.description as NSString)
            .trimmingCharacters(in: characterSet)
            .replacingOccurrences( of: " ", with: "") as String
        
        print(deviceTokenString)
        
    }

    
    

}





