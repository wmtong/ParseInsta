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

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var userMedia: [UserMedia]!
    var user: PFUser = PFUser.currentUser()!
    var window: UIWindow?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 360
        loadDataFromNetwork()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadDataFromNetwork()
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        loadDataFromNetwork()
        let proPic = user.objectForKey("photo")
        print(proPic)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //tableView methods that incorporate headerView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if userMedia != nil {
            return userMedia!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("imageIdentifier", forIndexPath: indexPath) as! ImageCell
        cell.media = userMedia![indexPath.section]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;
        if let proPic = user.valueForKey("photo") as? PFFile{
            proPic.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                
                if error == nil {
                    let image = UIImage(data:imageData!)
                    profileView.image = image
                }else{
                    print("Error: \(error)")
                }
            }
        }
        
        headerView.addSubview(profileView)
        let labelView = UILabel(frame: CGRect(x: 50, y: 10, width: 200, height: 30))
        let userPath = user["username"] as! String
        labelView.text = userPath
        labelView.font = UIFont(name: "MarkerFelt", size: 18)
        headerView.addSubview(labelView)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("iconTapGestureHandler:"))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        headerView.addGestureRecognizer(tapRecognizer)
        return headerView
    }
    
    //tapGesture methods on headerView to transfer to profile page
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func iconTapGestureHandler(sender:UIGestureRecognizer){
        self.tabBarController?.selectedIndex = 2

    }
    
    //load data method
    
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
