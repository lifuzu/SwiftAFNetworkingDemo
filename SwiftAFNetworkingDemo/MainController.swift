//
//  MainControllerTableViewController.swift
//  SwiftAFNetworkingDemo
//
//  Created by Richard Lee on 8/14/14.
//  Copyright (c) 2014 Weimed. All rights reserved.
//

import UIKit
import CoreLocation

class MainController: UITableViewController, UIActionSheetDelegate, WeatherHTTPClientDelegate, CLLocationManagerDelegate {

    // Properties
    var weather: NSDictionary = [:]
    var locationManager: CLLocationManager? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initial location manager
        self.locationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            NSLog("Staring CLLocationManager")
            switch(CLLocationManager.authorizationStatus()) {
            case CLAuthorizationStatus.NotDetermined:
                // User has not yet made a choice with regards to this application
                NSLog("User has not yet made a choice")
                break
            case CLAuthorizationStatus.Restricted:
                // This application is not authorized to use location services.  Due
                // to active restrictions on location services, the user cannot change
                // this status, and may not have personally denied authorization
                NSLog("This application is not authorized to use location services.")
                break
            case CLAuthorizationStatus.Denied:
                // User has explicitly denied authorization for this application, or
                // location services are disabled in Settings
                NSLog("User has explicitly denied authorization for this application.")
                break
            case CLAuthorizationStatus.Authorized:
                // User has authorized this application to use location services
                NSLog("User has authorized this application to use location services")
                break
            default:
                break
            }
            self.locationManager?.delegate = self
            self.locationManager?.distanceFilter = 200
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            NSLog("Cann't staring CLLocationManager")
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        // Display toolbar
        self.navigationController.setToolbarHidden(false, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        // Hide toolbar
        self.navigationController.setToolbarHidden(true, animated: true)
    }

    @IBAction func clear(sender: AnyObject) {
        self.title = ""
        self.weather = [:]
        self.tableView.reloadData()
    }

    @IBAction func actionTapped(sender: AnyObject) {
        var actionSheet = UIActionSheet(title: "AFHTTPSessionManager", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("HTTP GET")
        actionSheet.addButtonWithTitle("HTTP POST")
        //actionSheet.addButtonWithTitle("HTTP PUT")
        //actionSheet.addButtonWithTitle("HTTP DELETE")
        actionSheet.addButtonWithTitle("Test SubClass")
        // Refer to https://medium.com/@aommiez/afnetwork-integrate-swfit-80514b545b40

        actionSheet.showFromBarButtonItem(sender as UIBarButtonItem, animated: true)
    }

    // #pragma mark - UIActionSheetDelegate

    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        // actionSheet.cancelButtonIndex = 0
        if buttonIndex == 0 {
            return
        }

        NSLog("the index is %d", buttonIndex)
        var baseURL = NSURL(string: "http://www.raywenderlich.com/demos/weather_sample/")
        var parameters = ["format": "json"]

        var manager = AFHTTPSessionManager(baseURL: baseURL)
        manager.responseSerializer = AFJSONResponseSerializer()
        //manager.requestSerializer.setValue(“608c6c08443c6d933576b90966b727358d0066b4", forHTTPHeaderField: “X-Auth-Token”)

        if buttonIndex == 1 {
            manager.GET("weather.php", parameters: parameters, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                    self.weather = responseObject as NSDictionary
                    self.title = "JSON GETTED"
                    NSLog(self.weather.description)
                    self.tableView.reloadData()
                }, failure: { ( task: NSURLSessionDataTask!, error: NSError!) -> Void in
                    NSLog("GET failed: %@", error)
                    var alert = UIAlertController(title: "Error Retrieving Weather", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
            })
        } else if buttonIndex == 2 {
            manager.POST("weather.php", parameters: parameters, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                    self.weather = responseObject as NSDictionary
                    self.title = "JSON POSTED"
                    NSLog(self.weather.description)
                    self.tableView.reloadData()
                }, failure: { ( task: NSURLSessionDataTask!, error: NSError!) -> Void in
                    NSLog("POST failed: %@", error)
                    var alert = UIAlertController(title: "Error Retrieving Weather", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    // Handle actions within Alert
                    /*alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                    switch action.style{
                    case .Default:
                    println("default")
                    break

                    case .Cancel:
                    println("cancel")
                    break

                    case .Destructive:
                    println("destructive")
                    break
                    }
                    }))*/
            })
        } else if buttonIndex == 3 {
            NSLog("Starting update location")
            self.locationManager!.startUpdatingLocation()
        }
    }

    // #pragma mark - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Last object contains the most recent location
        var newLocation = locations.last as CLLocation
        // If the location is more than 5 minutes old, ignore it
        if newLocation.timestamp.timeIntervalSinceNow > 300 { return }

        self.locationManager!.stopUpdatingLocation()

        var client = WeatherHTTPClient.sharedInstance
        client.delegate = self
        client.updateWeatherAtLocation(location: newLocation, forNumberOfDays: 5)
    }

    // #pragma mark - WeatherHTTPClientDelegate

    func weatherHTTPClient(#client: WeatherHTTPClient, didUpdateWithWeather weather: AnyObject) {
        self.weather = weather as NSDictionary
        self.title = "API Updated"
        self.tableView.reloadData()
    }

    func weatherHTTPClient(#client: WeatherHTTPClient, didFailWithError error: NSError) {
        var alert = UIAlertController(title: "Error Retrieving Weather", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if self.weather.count == 0 { return 0 }

        switch section {
        case 0:
            return 1
        case 1:
            let upcomingWeather = self.weather["data"]["weather"] as NSArray
            return upcomingWeather.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("WeatherCell", forIndexPath: indexPath) as UITableViewCell

        var daysWeather: NSDictionary = [:]
        switch (indexPath.section) {
        case 0:
            let currentCondition = self.weather["data"]["current_condition"] as NSArray
            daysWeather = currentCondition[0] as NSDictionary
        case 1:
            let upcomingWeather: AnyObject! = self.weather["data"]["weather"] as NSArray
            daysWeather = upcomingWeather[indexPath.row] as NSDictionary
        default:
            break
        }

        // Display string
        let weatherDesc = daysWeather["weatherDesc"] as NSArray
        cell.textLabel.text = weatherDesc[0]["value"] as NSString

        // Fetch icon according to the icon url in json
        let weatherIconUrl = daysWeather["weatherIconUrl"] as NSArray
        let url = NSURL(string: weatherIconUrl[0]["value"] as NSString)
        let request = NSURLRequest(URL: url)
        var placeholderImage = UIImage(named: "placeholder")

        // Display icon
        cell.imageView.setImageWithURLRequest(request, placeholderImage: placeholderImage, success: { [weak cell] request, response, image in
                if cell != nil {
                    cell!.imageView.image = image
                }

                if (tableView.visibleCells() as NSArray).containsObject(cell) {
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }, failure: {request, response, error in
                NSLog("%@", error)
            })

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
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
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "WeatherDetailSegue" {
            var cell = sender as UITableViewCell
            var indexPath = self.tableView.indexPathForCell(cell)

            let vc = segue.destinationViewController as ViewController
            switch indexPath.section {
            case 0:
                let currentCondition = self.weather["data"]["current_condition"] as NSArray
                vc.weather = currentCondition[0] as NSDictionary
                NSLog(vc.weather.description)
            case 1:
                let upcomingWeather: AnyObject! = self.weather["data"]["weather"] as NSArray
                vc.weather = upcomingWeather[indexPath.row] as NSDictionary
                NSLog(vc.weather.description)
            default:
                break
            }
        }
    }

}
