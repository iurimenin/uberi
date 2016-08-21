//
//  RequestViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Iuri Menin on 21/08/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {

    var requestLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0)
    var requestUsername: String = ""
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func pickUpRider(sender: AnyObject) {
    
        let query = PFQuery(className: "passageiroRequest")
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            
            if error == nil {
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        let responseQuey = PFQuery(className: "passageiroRequest")
                        print(object.objectId!)
                        responseQuey.getObjectInBackgroundWithId(object.objectId!, block: { (objectPassageiro, error) in
                            
                            if error != nil {
                                
                                print(error)
                            } else if let objectPassageiro = objectPassageiro {
                                
                                print(objectPassageiro)
                                print(PFUser.currentUser()!.username!)
                                
                                objectPassageiro["driverResponded"] = PFUser.currentUser()!.username!
                                objectPassageiro.saveInBackgroundWithBlock({ (sucesso, error) in
                                    print(sucesso)
                                    print(error)
                                })
                                
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                                    
                                    if error != nil {
                                        print(error)
                                    } else {
                                        
                                        if placemarks?.count > 0 {
                                            
                                            let pm = placemarks![0] 
                                            let mkPm = MKPlacemark(placemark: pm)
                                            let mapItem = MKMapItem(placemark: mkPm)
                                            
                                            mapItem.name = self.requestUsername
                                            
                                            let lauchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                            
                                            mapItem.openInMapsWithLaunchOptions(lauchOptions)
                                        }
                                    }
                                })
                            }
                        })
                   }
                }
                
            } else {
                
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        let pinAnotation = MKPointAnnotation()
        pinAnotation.coordinate = requestLocation
        pinAnotation.title = requestUsername
        
        self.map.addAnnotation(pinAnotation)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
