//
//  TimelineViewController.swift
//  ParseInsta
//
//  Created by William Tong on 3/1/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userMedia: [UserMedia]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 360
        
        loadDataFromNetwork()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        loadDataFromNetwork()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userMedia != nil {
            return userMedia!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("imageIdentifier", forIndexPath: indexPath) as! ImageCell
        cell.media = userMedia![indexPath.row]
        return cell
    }
    
    func loadDataFromNetwork() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let url = NSURL(string: "https://nameless-journey-97449.herokuapp.com/parse")
        let request = NSURLRequest(URL: url!)
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                let query = PFQuery(className: "UserMedia")
                query.orderByDescending("createdAt")
                query.includeKey("author")
                query.limit = 20
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)

                // fetch data asynchronously
                query.findObjectsInBackgroundWithBlock { (media: [PFObject]?, error: NSError?) -> Void in
                    if let media = media {
                        let tempMedia = UserMedia.mediaWithArray(media)
                        UserMedia.processFilesWithArray(tempMedia, completion: { () -> Void in
                            print("reloading table")
                            self.tableView.reloadData()
                        })
                        self.userMedia = tempMedia
                    } else {
                        // handle error
                        print("error fetching data")
                    }
                }
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)

                // ... Remainder of response handling code ...
                
        });
        task.resume()
    }
    

}
