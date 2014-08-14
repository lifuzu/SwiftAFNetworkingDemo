//
//  WeatherHTTPClient.swift
//  SwiftAFNetworkingDemo
//
//  Created by Richard Lee on 8/13/14.
//  Copyright (c) 2014 Weimed. All rights reserved.
//

import Foundation
import CoreLocation

@objc
protocol WeatherHTTPClientDelegate {
    optional func weatherHTTPClient(#client: WeatherHTTPClient, didUpdateWithWeather weather: AnyObject)
    optional func weatherHTTPClient(#client: WeatherHTTPClient, didFailWithError error: NSError)
}

// Reference: https://developer.worldweatheronline.com/ - How to apply YOUR API KEY
let WorldWeatherOnlineAPIKey = "PASTE YOUR API KEY HERE"
let WorldWeatherOnlineURLString = "http://api.worldweatheronline.com/free/v1/"
let WeatherHTTPClientSharedInstance = WeatherHTTPClient(baseURL: NSURL.URLWithString(WorldWeatherOnlineURLString))

class WeatherHTTPClient: AFHTTPSessionManager {
    var delegate: WeatherHTTPClientDelegate?

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override init(baseURL url: NSURL!) {
        super.init(baseURL: url, sessionConfiguration: nil)

        requestSerializer = AFJSONRequestSerializer()
        responseSerializer = AFJSONResponseSerializer()

        requestSerializer.setValue(WorldWeatherOnlineAPIKey, forHTTPHeaderField: "X-Api-Key")
        requestSerializer.setValue("3", forHTTPHeaderField: "X-Api-Version")
    }

    class var sharedInstance: WeatherHTTPClient {
        return WeatherHTTPClientSharedInstance
    }

    func updateWeatherAtLocation(#location: CLLocation, forNumberOfDays number: UInt) {
        var parameters = ["num_of_days": number, "format": "json", "key": WorldWeatherOnlineAPIKey] as Dictionary
        parameters["q"] = NSString(format: "%f,%f", location.coordinate.latitude, location.coordinate.longitude)
        //parameters["q"] = "32.35,141.43"

        self.GET("weather.ashx", parameters: parameters, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                self.delegate?.weatherHTTPClient?(client: self, didUpdateWithWeather: responseObject)
                var weather = responseObject as NSDictionary
                NSLog(weather.description)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                NSLog("GET failed: %@", error)
                self.delegate?.weatherHTTPClient?(client: self, didFailWithError: error)
        })
    }
}