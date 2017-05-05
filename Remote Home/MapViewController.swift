//
//  MapViewController.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 29/03/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var mkOverlay:MKOverlay!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var radiusDistanceLabel: UILabel!
    @IBOutlet weak var sliderChangeRadius: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.mapView.delegate = self
        
        self.mapView.showsUserLocation = true
        
        self.sliderChangeRadius.value = Float(GlobalVariables.sharedInstance.actualDevice.radius)
        self.radiusDistanceLabel.text = String(format: "%.02f Km", self.sliderChangeRadius.value)
        
        print(GlobalVariables.sharedInstance.user.latitude)
        print(GlobalVariables.sharedInstance.user.longitude)
        self.pointAnnotation = MKPointAnnotation()
        if(GlobalVariables.sharedInstance.actualDevice.latitude != 0.0 && GlobalVariables.sharedInstance.actualDevice.longitude != 0.0) {
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude:GlobalVariables.sharedInstance.actualDevice.latitude, longitude:GlobalVariables.sharedInstance.actualDevice.longitude)
        } else {
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude:GlobalVariables.sharedInstance.user.latitude, longitude:GlobalVariables.sharedInstance.user.longitude)
        }
        
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: self.pointAnnotation.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        let userAnnotationView:MKPinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.addAnnotation(userAnnotationView.annotation!)
        self.removeAndPaintNewMkCircleInOverlay()
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.handleTap(_:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude:localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: self.pointAnnotation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            self.removeAndPaintNewMkCircleInOverlay()
        }
    }
    
    //MARK: Actions
    
    @IBAction func showSearchBar(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func changedRadiusSlider(_ sender: AnyObject) {
        print(self.sliderChangeRadius.value)
        self.radiusDistanceLabel.text = String(format: "%.02f Km", self.sliderChangeRadius.value)
        
        self.removeAndPaintNewMkCircleInOverlay()
        
    }
    
    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let point:CGPoint = gestureRecognizer.location(in: self.mapView)
        let tappedPoint:CLLocationCoordinate2D = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        self.pointAnnotation.coordinate = tappedPoint;
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: self.pointAnnotation.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        self.removeAndPaintNewMkCircleInOverlay()
    }
    
    
    // MARK: MapView Delegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            return circleRenderer
        }
        
        return MKPolygonRenderer()
    }
    
    
    func removeAndPaintNewMkCircleInOverlay() {
        if(self.pointAnnotation != nil) {
            if(self.mkOverlay != nil) {
                self.mapView.remove(self.mkOverlay)
            }
            self.mkOverlay = MKCircle(center: self.pointAnnotation.coordinate, radius: CLLocationDistance(self.sliderChangeRadius.value*1000))
            self.mapView.add(self.mkOverlay)
            if(Double(self.pointAnnotation.coordinate.latitude) != GlobalVariables.sharedInstance.actualDevice.latitude || Double(self.pointAnnotation.coordinate.longitude) != GlobalVariables.sharedInstance.actualDevice.longitude) {
                var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
                var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
                var deviceLatitude = ["device_latitude": Double(self.pointAnnotation.coordinate.latitude)]
                var deviceLongitude = ["device_longitude": Double(self.pointAnnotation.coordinate.longitude)]
                var deviceRadius = ["device_radius": self.sliderChangeRadius.value]
                
                deviceRef.updateChildValues(deviceLatitude)
                deviceRef.updateChildValues(deviceLongitude)
                deviceRef.updateChildValues(deviceRadius)
                
                
                refDevices = FIRDatabase.database().reference().child("devices_general");
                deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
                deviceLatitude = ["device_latitude": Double(self.pointAnnotation.coordinate.latitude)]
                deviceLongitude = ["device_longitude": Double(self.pointAnnotation.coordinate.longitude)]
                deviceRadius = ["device_radius": self.sliderChangeRadius.value]
                
                deviceRef.updateChildValues(deviceLatitude)
                deviceRef.updateChildValues(deviceLongitude)
                deviceRef.updateChildValues(deviceRadius)
                
                GlobalVariables.sharedInstance.actualDevice.latitude = self.pointAnnotation.coordinate.latitude
                GlobalVariables.sharedInstance.actualDevice.longitude = self.pointAnnotation.coordinate.longitude
                GlobalVariables.sharedInstance.actualDevice.radius = Double(self.sliderChangeRadius.value)
            }
            if(self.sliderChangeRadius.value != Float(GlobalVariables.sharedInstance.actualDevice.radius)) {
                var refDevices = FIRDatabase.database().reference().child("devices").child(GlobalVariables.sharedInstance.user.userUID);
                var deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
                var deviceRadius = ["device_radius": self.sliderChangeRadius.value]
                
                deviceRef.updateChildValues(deviceRadius)
                
                
                refDevices = FIRDatabase.database().reference().child("devices_general");
                deviceRef = refDevices.child(GlobalVariables.sharedInstance.actualDevice.deviceUID)
                deviceRadius = ["device_radius": self.sliderChangeRadius.value]
                
                deviceRef.updateChildValues(deviceRadius)
                
                GlobalVariables.sharedInstance.actualDevice.radius = Double(self.sliderChangeRadius.value)
            }
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
