//
//  CaptureViewController.swift
//  ParseInsta
//
//  Created by William Tong on 3/1/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicked: UIImage?
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var captionText: UITextField!
    @IBOutlet weak var submitView: UIView!
    
    var userMedia: UserMedia!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.image = nil
        takePictureButton.hidden = false
        takePictureButton.layer.cornerRadius = 10.0
        takePictureButton.clipsToBounds = true
        submitView.layer.cornerRadius = 10.0
        submitView.clipsToBounds = true
    }
    
    /*
    @IBAction func openCamera(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(vc, animated: true, completion: nil)
    }*/
    
    //photoselection methods
    @IBAction func openPhotos(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            imagePicked = resize(editedImage,newSize: editedImage.size)
            imageView.image = imagePicked
            takePictureButton.hidden = true
    }

    @IBAction func uploadPhoto(sender: AnyObject) {
        if(takePictureButton.hidden==true){
        UserMedia.postUserImage(imagePicked, withCaption: captionText.text, withCompletion: { (result) -> Void in
            print("upload successful")
            let newPost = UserMedia(image: self.imagePicked!, caption: self.captionText.text!, likesCount: 0, commentsCount: 0)
            
            self.imageView.image = nil
            self.captionText.text = nil
            
            NSNotificationCenter.defaultCenter().postNotificationName("PostSubmitted", object: nil, userInfo: ["Post" : newPost])
            
            self.tabBarController?.selectedIndex = 0
            self.takePictureButton.hidden = false
        })
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
