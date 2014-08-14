//
//  MainControllerTableViewController.swift
//  SwiftAFNetworkingDemo
//
//  Created by Richard Lee on 8/14/14.
//  Copyright (c) 2014 Weimed. All rights reserved.
//

import UIKit

class MainController: UITableViewController, UIActionSheetDelegate {

    // Properties
    var weather: NSDictionary = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

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
            var client = WeatherHTTPClient.sharedInstance
            client.updateWeatherAtLocation(/*location: "2,3", */forNumberOfDays: 5)
        }
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

        let weatherDesc = daysWeather["weatherDesc"] as NSArray
        cell.textLabel.text = weatherDesc[0]["value"] as NSString
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
