//
//  LocationViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 30/03/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UITableViewDelegate {

    
    var savedProfile: [AnyHashable: Any] = [:]
    var locationArray: [AnyObject] = []
    
    @IBOutlet var modeSeg: UISegmentedControl!
    @IBOutlet var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Action Reload Data
    
    func reloadData() {
        let docDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fullPath: String = "\(docDir)/\("LocationArray.plist")"
        if let savedProfile = NSMutableDictionary(contentsOfFile: fullPath) {
            if savedProfile.count != 0 {
                //Sort
//                locationArray = (savedProfile["LocationArray"] as! NSArray).sortedArray(using: [NSSortDescriptor(key: "Time", ascending:false)])
                if modeSeg.selectedSegmentIndex == 1 {
//                    let temp: NSMutableArray = [].mutableCopy() as! NSMutableArray
//                    for dic in locationArray as! [NSDictionary] {
//                        if (dic["Accuracy"] != nil) {
//                            temp.add(dic)
//                        }
//                    }
//                    locationArray = temp as [AnyObject]
                }
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func modeDidChanged(_ sender: UISegmentedControl) {
        self.reloadData()
    }
    
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(locationArray)
        return locationArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dic: NSMutableDictionary = locationArray[indexPath.row] as! NSMutableDictionary
        let appState: String = "App State : \((dic["AppState"]! as AnyObject).replacingOccurrences(of: "UIApplicationState", with: ""))"
        let date: Date = dic.object(forKey: "Time") as! Date
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let time: String = dateFormatter.string(from: date)
        
        //print( dic.objectForKey("Accuracy"))
        
        if let accuracy: Double = dic.object(forKey: "Accuracy") as? Double {
            let location: String = String(format: "Location : %.06f , %.06f", CFloat(dic.object(forKey: "Latitude") as! CGFloat), CFloat(dic.object(forKey: "Longitude") as! CGFloat))
        
            let addFromResum: String = String(format: "Add From Resume: %@", ((dic.object(forKey: "AddFromResume") as AnyObject).boolValue as CVarArg))
            cell.textLabel!.text = "\(appState)\n\(addFromResum)\n\(accuracy)\n\(location)\n\(time)"
        }
        else if let resume: String = dic.object(forKey: "Resume") as? String {
            cell.textLabel!.text = "\(appState)\n\(resume)\n\(time)\n\n"
        }
        else {
            cell.textLabel!.text = "\(appState)\n\(dic["applicationStatus"])\n\(time)\n\n"
        }
        
        return cell
        
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
