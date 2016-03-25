//
//  ProfileViewController.swift
//  ParseInsta
//
//  Created by William Tong on 3/1/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var proPic: UIImageView!
    var imagePicked: UIImage?
    @IBOutlet weak var takePictureButton: UIButton!
    var user: PFUser = PFUser.currentUser()!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        proPicExists()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        proPic.layer.cornerRadius = 10.0
        proPic.clipsToBounds = true
        buttonView.layer.cornerRadius = 10.0
        buttonView.clipsToBounds = true
        logoutView.layer.cornerRadius = 10.0
        logoutView.clipsToBounds = true
        proPicExists()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //add a propic
    func proPicExists(){
        if(user.valueForKey("photo") != nil){
            if let proPic = user.valueForKey("photo") as? PFFile{
                proPic.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData!)
                        self.proPic.image = image
                    }else{
                        print("Error: \(error)")
                    }
                }
            }
            takePictureButton.setTitle("Update Profile Pic", forState: .Normal)
        }
    }
    
    @IBAction func addProPic(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            imagePicked = resize(editedImage,newSize: editedImage.size)
            proPic.image = imagePicked
            let imageData = UIImagePNGRepresentation(imagePicked!)
            let imageFile = PFFile(name: "image.png", data: imageData!)
            PFUser.currentUser()!.setObject(imageFile!, forKey: "photo")
            user.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
            }
            takePictureButton.setTitle("Update Profile Pic", forState: .Normal)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
    }
}
