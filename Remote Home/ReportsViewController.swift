//
//  ReportsViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 18/04/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import Charts

class ReportsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var barChartView: BarChartView!
    //var months: [String]!
    var unitsSold:[Double] = []
    var months:[String] = []
    var dayConsumption:Double = 0.0
    var lastDay:String = ""
    var uniqueDay:[Double] = []
    var hours:[String] = []
    var array:NSMutableArray! = []
    var countData:Int = 0
    var canEntryOnSelection:Bool = false
    var shouldShowLastWeek:Bool = true
    var didEntryOnConversionType:Bool = false
    var myHoursValuesGlobal:[Double] = []
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var changeConversionType: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeConversionType.title = "Consumo"
        
        self.canEntryOnSelection = true
        
        //self.view.showLoading()
        
        let ref = FIRDatabase.database().reference().child("consumption").child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
        
        self.view.showLoading()
        //ref.childByAppendingPath(GlobalVariables.sharedInstance.user.devicesList.objectAtIndex(index) as! String)
        ref.queryOrderedByValue().observe(.childAdded, with: { snapshot in
            
            if let time = (snapshot.value! as AnyObject).object(forKey: "date") as? Double {
                let date = Date(timeIntervalSince1970:time/1000)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM"
                let str = dateFormatter.string(from: date)
                print(str)
                
                if let consumption = (snapshot.value! as AnyObject).object(forKey: "consumption") as? String {
                    
                    let dictionary:NSMutableDictionary! = [:]
                    dictionary.setObject(str, forKey: "date" as NSCopying)
                    dictionary.setObject(consumption, forKey: "consume" as NSCopying)
                    self.array.add(dictionary)
                    
                }
                
                if(self.lastDay != str) {
                    
                    if(self.months.count > 0) {
                        let str:String = self.months.last!
                        for i in 0..<self.array.count {
                            let dic:NSMutableDictionary = self.array.object(at: i) as! NSMutableDictionary
                            if(dic.object(forKey: "date") as! String == str) {
                                // fica aqui pegando os valores do dia
                                let day:Double = Double(dic.object(forKey: "consume") as! String)!
                                if(day > 0.1) {
                                    self.countData += 1;
                                    self.dayConsumption += (day*day)
                                } else {
                                    self.countData += 1;
                                    self.dayConsumption += 0
                                }
                            }
                        }
                        // aqui ele faz a média quadrática dos dias e associa ao gráfico
                        self.dayConsumption = self.dayConsumption/Double(self.countData)
                        self.dayConsumption = sqrt(self.dayConsumption)
                        self.dayConsumption = self.dayConsumption/(sqrt(2))
                        // multiplicado por 127V e divido por 1000 p/ ser em kW
                        self.unitsSold.append((self.dayConsumption*0.0167*127))
                        self.dayConsumption = 0.0
                        self.countData = 0
                    }
                    // para não carregar previamente
                    //self.setChart(self.months, values: self.unitsSold)
                    
                    self.months.append(str)
                    self.lastDay = str
                }
                
            }
            
            
        })
        
        
        barChartView.noDataText = "Sem dados disponíveis"
        
        
        barChartView.delegate = self
        
        
//        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateLastDayIn), userInfo: nil, repeats: false)

        // Do any additional setup after loading the view.
    }
    
    func isBetweeenDates(date date1: Date, andDate date2: Date, andMiddleDate date3: Date) -> Bool {
        let userCalendar = Calendar.current
        var addDayComponents = DateComponents()
        addDayComponents.day = 1
        var lessDayComponents = DateComponents()
        lessDayComponents.day = -1
        let dateByAdd = (userCalendar as NSCalendar).date(byAdding: lessDayComponents, to: date1, options: NSCalendar.Options(rawValue: 0))!
        let dateByLess = (userCalendar as NSCalendar).date(byAdding: addDayComponents, to: date2, options: NSCalendar.Options(rawValue: 0))!
        return dateByAdd.compare(date3).rawValue * date3.compare(dateByLess).rawValue >= 0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filterButton.isEnabled = true
        
        if(GlobalVariables.sharedInstance.shouldReloadGraphics) {
            // clear all variables before anything
            self.array.removeAllObjects()
            self.uniqueDay.removeAll()
            self.hours.removeAll()
            self.months.removeAll()
            self.unitsSold.removeAll()
            
            
            GlobalVariables.sharedInstance.shouldReloadGraphics = false
            
            self.canEntryOnSelection = true
            
            //self.view.showLoading()
            
            let ref = FIRDatabase.database().reference().child("consumption").child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
            
            self.view.showLoading()
            //ref.childByAppendingPath(GlobalVariables.sharedInstance.user.devicesList.objectAtIndex(index) as! String)
            ref.queryOrderedByValue().observe(.childAdded, with: { snapshot in
                
                if let time = (snapshot.value! as AnyObject).object(forKey: "date") as? Double {
                    let date = Date(timeIntervalSince1970:time/1000)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM"
                    let str = dateFormatter.string(from: date)
                    print(str)
                    
                    if(self.isBetweeenDates(date: GlobalVariables.sharedInstance.initialDate as Date, andDate: GlobalVariables.sharedInstance.endDate as Date, andMiddleDate: date)) {
                        if let consumption = (snapshot.value! as AnyObject).object(forKey: "consumption") as? String {
                            
                            let dictionary:NSMutableDictionary! = [:]
                            dictionary.setObject(str, forKey: "date" as NSCopying)
                            dictionary.setObject(consumption, forKey: "consume" as NSCopying)
                            self.array.add(dictionary)
                            
                        }
                        
                        if(self.lastDay != str) {
                            
                            if(self.months.count > 0) {
                                let str:String = self.months.last!
                                for i in 0..<self.array.count {
                                    let dic:NSMutableDictionary = self.array.object(at: i) as! NSMutableDictionary
                                    if(dic.object(forKey: "date") as! String == str) {
                                        // fica aqui pegando os valores do dia
                                        let day:Double = Double(dic.object(forKey: "consume") as! String)!
                                        if(day > 0.1) {
                                            self.countData += 1;
                                            self.dayConsumption += (day*day)
                                        } else {
                                            self.countData += 1;
                                            self.dayConsumption += 0
                                        }
                                    }
                                }
                                // aqui ele faz a média quadrática dos dias e associa ao gráfico
                                self.dayConsumption = self.dayConsumption/Double(self.countData)
                                self.dayConsumption = sqrt(self.dayConsumption)
                                self.dayConsumption = self.dayConsumption/(sqrt(2))
                                self.unitsSold.append((self.dayConsumption*0.0167*127))
                                self.dayConsumption = 0.0
                                self.countData = 0
                            }
                            // para não carregar previamente
                            //self.setChart(self.months, values: self.unitsSold)
                            
                            self.months.append(str)
                            self.lastDay = str
                        }
                    } else {
                        
                    }
                    
                    
                    
                }
                
                
            })
            
            
            barChartView.noDataText = "Sem dados disponíveis"
            
            
            barChartView.delegate = self
            
            
            //        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            //        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
            
            let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateLastDayIn), userInfo: nil, repeats: false)
        }
        
    }
    
    
    
    func updateLastDayIn () {
        
//        for j in 0..<self.months.count {
//            let str:String = self.months[j]
//            for i in 0..<self.array.count {
//                let dic:NSMutableDictionary = self.array.objectAtIndex(i) as! NSMutableDictionary
//                if(dic.objectForKey("date") as! String == str) {
//                    self.dayConsumption += Double(dic.objectForKey("consume") as! String)!
//                }
//            }
//            self.unitsSold.append(self.dayConsumption)
//            self.dayConsumption = 0.0
//        }
//                            
//        self.setChart(self.months, values: self.unitsSold)
    
        
        
        if(self.months.count > 0) {
            let str:String = self.months.last!
            for i in 0..<self.array.count {
                let dic:NSMutableDictionary = self.array.object(at: i) as! NSMutableDictionary
                if(dic.object(forKey: "date") as! String == str) {
                    // fica aqui pegando os valores do dia
                    let day:Double = Double(dic.object(forKey: "consume") as! String)!
                    if(day > 0.1) {
                        self.countData += 1;
                        self.dayConsumption += (day*day)
                    } else {
                        self.countData += 1;
                        self.dayConsumption += 0
                    }
                }
            }
            self.dayConsumption = self.dayConsumption/Double(self.countData)
            self.dayConsumption = sqrt(self.dayConsumption)
            self.dayConsumption = self.dayConsumption/(sqrt(2))
            self.unitsSold.append((self.dayConsumption*0.0167*127))
            self.dayConsumption = 0.0
            self.countData = 0
        }
        
        self.view.hideLoading()
        // manha para fazer ele mostrar só a última semana
        while(self.months.count > 7 && self.shouldShowLastWeek) {
            self.months.removeFirst()
            self.unitsSold.removeFirst()
        }
        self.shouldShowLastWeek = false
        self.setChart(self.months, values: self.unitsSold)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setChart(_ dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: values[i], y: Double(i))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: GlobalVariables.sharedInstance.actualDevice.deviceName)
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.descriptionText = ""
        
        //chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
//                chartDataSet.colors = ChartColorTemplates.colorful()
        
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.wordWrapEnabled = false
        barChartView.xAxis.labelHeight = 20.0
        
        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
        
        //let ll = ChartLimitLine(limit: 10.0, label: "Target")
        //barChartView.rightAxis.addLimitLine(ll)
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        
        if(self.canEntryOnSelection) {
            self.filterButton.isEnabled = false
            
            self.canEntryOnSelection = false
            self.view.showLoading()
            
            let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateHoursOfOneDay), userInfo: nil, repeats: false)
            
            let ref = FIRDatabase.database().reference().child("consumption").child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
            
            //ref.childByAppendingPath(GlobalVariables.sharedInstance.user.devicesList.objectAtIndex(index) as! String)
            ref.queryOrderedByValue().observe(.childAdded, with: { snapshot in
                
                if let time = (snapshot.value! as AnyObject).object(forKey: "date") as? Double {
                    let date = Date(timeIntervalSince1970:time/1000)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM"
                    let str = dateFormatter.string(from: date)
                    
                    if(str == self.months[dataSetIndex]) {
                        dateFormatter.dateFormat = "HH:mm"
                        let str = dateFormatter.string(from: date)
                        self.hours.append(str)
                        
                        if let consumption = (snapshot.value! as AnyObject).object(forKey: "consumption") as? String {
                            self.uniqueDay.append(Double(consumption)!)
                        }
                        
                    }
                    
                    
                }
                
            })
            
        }
    }
    

    func updateHoursOfOneDay() {
        
        var myHoursValues:[Double] = []
        var adding:Double = 0.0
        
        let myHoursofDay:[String] = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","00"]
        
        for i in 0..<myHoursofDay.count {
            for j in 0..<self.hours.count {
                let str:String = self.hours[j]
                if(str.components(separatedBy: ":").first! == myHoursofDay[i]) {
                    adding = adding + (self.uniqueDay[j] * self.uniqueDay[j])
                }
            }
            adding = adding/Double(self.hours.count)
            adding = sqrt(adding)
            adding = adding/(sqrt(2))
            myHoursValues.append((adding*0.0167*127))
            adding = 0.0
        }
        self.view.hideLoading()
        self.myHoursValuesGlobal = myHoursValues
        self.setChart(myHoursofDay, values: myHoursValues)
    }
    
    
    @IBAction func didClickedToChangeConversionType(_ sender: UIBarButtonItem) {
        
        self.didEntryOnConversionType = !self.didEntryOnConversionType
        
        if(self.didEntryOnConversionType) {
            self.changeConversionType.title = "Potência"
        } else {
            self.changeConversionType.title = "Consumo"
        }
        
        if(self.hours.count > 0 && GlobalVariables.sharedInstance.user.energyCost > 0.0) {
            self.view.showLoading()
            let myHoursofDay:[String] = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","00"]
            
            for i in 0..<self.myHoursValuesGlobal.count {
                if(self.didEntryOnConversionType) {
                    self.myHoursValuesGlobal[i] = self.myHoursValuesGlobal[i] * GlobalVariables.sharedInstance.user.energyCost
                } else {
                    self.myHoursValuesGlobal[i] = self.myHoursValuesGlobal[i] / GlobalVariables.sharedInstance.user.energyCost
                }
            }
            self.view.hideLoading()
            self.setChart(myHoursofDay, values: self.myHoursValuesGlobal)
        } else if(self.months.count > 0 && GlobalVariables.sharedInstance.user.energyCost > 0.0) {
            self.view.showLoading()
            for i in 0..<self.unitsSold.count {
                if(self.didEntryOnConversionType) {
                    self.unitsSold[i] = self.unitsSold[i] * GlobalVariables.sharedInstance.user.energyCost
                } else {
                    self.unitsSold[i] = self.unitsSold[i] / GlobalVariables.sharedInstance.user.energyCost
                }
            }
            self.setChart(self.months, values: self.unitsSold)
            self.view.hideLoading()
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
