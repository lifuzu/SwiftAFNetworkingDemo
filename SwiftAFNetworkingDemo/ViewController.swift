//
//  ViewController.swift
//  SwiftAFNetworkingDemo
//
//  Created by Richard Lee on 8/11/14.
//  Copyright (c) 2014 Weimed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //SVProgressHUD.showProgress(20.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func downloadImage(sender: AnyObject) {
        var url = NSURL.URLWithString("http://www.raywenderlich.com/wp-content/uploads/2014/01/sunny-background.png")
        var request = NSURLRequest(URL: url)

        var operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFImageResponseSerializer()
        operation.setCompletionBlockWithSuccess( { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                println("JSON: " + responseObject.description)
                self.imageView.image = responseObject as UIImage
                self.saveImage(self.imageView.image, withFileName: "background.png")
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error: " + error.localizedDescription)
            }
        )
        operation.start()
    }

    func saveImage(image: UIImage, withFileName filename: String) {
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        path = path.stringByAppendingPathComponent("SwiftAFNetworkingDemoImages/")
        
        var isDir: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) == nil {
            if isDir == nil {
                var error: NSError? = nil
                NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)
                NSLog("%@", error!)
            }
        }
        path = path.stringByAppendingPathComponent(filename)
        var imageData = UIImagePNGRepresentation(image)
        NSLog("Writting: %d", imageData.writeToFile(path, atomically: true))
    }

    func loadImageWithFileName(filename: String) -> UIImage {
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        path = path.stringByAppendingPathComponent("SwiftAFNetworkingDemoImages/")
        path = path.stringByAppendingPathComponent(filename)

        return UIImage(contentsOfFile: path)
    }
}

