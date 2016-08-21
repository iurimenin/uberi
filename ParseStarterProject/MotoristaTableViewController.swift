//
//  MotoristaTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Iuri Menin on 19/08/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

@available(iOS 8.0, *)
class MotoristaTableViewController: UITableViewController, CLLocationManagerDelegate {

    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = location.latitude
        longitude = location.longitude
        
        let driverQuery = PFQuery(className: "driverLocation")
        driverQuery.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        driverQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            
            if error == nil {
                
                if let objects = objects {
                    
                    if objects.count > 0 {
                        
                        for object in objects {
                            
                            let query = PFQuery(className: "driverLocation")
                            query.getObjectInBackgroundWithId(object.objectId!, block: { (obj, error) in
                                
                                if error != nil {
                                    print(error)
                                } else {
                                    
                                    if let object = obj {
                                        
                                        object["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                                        object.saveInBackground()
                                    }
                                }
                            })
                        }
                    } else {
                       
                        let driverLocation = PFObject(className: "driverLocation")
                        driverLocation["username"] = PFUser.currentUser()?.username
                        driverLocation["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                        driverLocation.saveInBackground()
                    }
                }
            } else {
                
                print(error)
            }
        }
        
        let query = PFQuery(className: "passageiroRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error) in
            
            if error == nil {
            
                if let objects = objects {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        if let username = object["username"] as? String {
                            
                            self.usernames.append(username)
                        }
                        
                        if let locationRetorno = object["location"] as? PFGeoPoint {
                            
                            let requestLocation = CLLocationCoordinate2DMake(locationRetorno.latitude, locationRetorno.longitude)
                            self.locations.append(requestLocation)
                            
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            let driverLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                            let distance = driverLocation.distanceFromLocation(requestCLLocation)
                            
                            self.distances.append(distance / 1000)
                        }
                    }
                    
                    self.tableView.reloadData()
                }
            } else {
                
                print("error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutMotorista" {
            navigationController?.navigationBar.hidden = true
            PFUser.logOut()
            
        } else if segue.identifier == "showViewRequest" {
            
            if let destination = segue.destinationViewController as? RequestViewController {
                
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
        
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        let distanceDouble = Double(distances[indexPath.row])
        let roundedDistance = Double(round(distanceDouble * 10) / 10)
        cell.textLabel?.text = usernames[indexPath.row] + ": " + String(roundedDistance) + " Km distante"

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
