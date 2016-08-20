//
//  PassegueiroViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Iuri Menin on 19/08/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

@available(iOS 8.0, *)
class PassegueiroViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var passageiroChamouUber = false
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var locationManager: CLLocationManager!
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var callUberiButton: UIButton!
    
    @IBAction func chamarUber(sender: AnyObject) {
    
        if !passageiroChamouUber {
            let passageiroRequest = PFObject(className: "passageiroRequest")
            passageiroRequest["username"] = PFUser.currentUser()?.username
            passageiroRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            passageiroRequest.saveInBackgroundWithBlock { (success, error) in
                
                if success {
                    
                    self.callUberiButton.setTitle("Cancelar Uberi", forState: .Normal)
                    self.passageiroChamouUber = true
                } else {
                    
                    let alert = UIAlertController(title: "Não foi possivel chamar um Uberi",
                        message: "Por favor tente novamente.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else {
            
            self.callUberiButton.setTitle("Chamar Uberi", forState: .Normal)
            self.passageiroChamouUber = false
            
            let query = PFQuery(className: "passageiroRequest")
            query.whereKey("username", lessThan: PFUser.currentUser()!.username!)
            
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                
                if error == nil {
                    
                    if let objects = objects {
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                        }
                    }
                } else {
                    
                    print(error)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        //print("location = \(location.latitude) \(location.longitude)")
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        let pinLocation = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let pinAnotation = MKPointAnnotation()
        pinAnotation.coordinate = pinLocation
        pinAnotation.title = "Você está aqui"

        self.map.addAnnotation(pinAnotation)
        
        latitude = location.latitude
        longitude = location.longitude
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutPassageiro" {
            PFUser.logOut()
        }
    }
}
