//
//  UserMedia.swift
//  ParseInsta
//
//  Created by William Tong on 3/1/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class UserMedia: NSObject {
    var mediaFile: PFFile?
    var image: UIImage?
    var caption: String?
    var likesCount: Int?
    var commentsCount: Int?

    init(image: UIImage, caption: String, likesCount: Int, commentsCount: Int) {
        self.image = image
        self.caption = caption
        self.likesCount = likesCount
        self.commentsCount = commentsCount
    }
    
    init(object: PFObject) {
        mediaFile = object["media"] as? PFFile
        caption = object["caption"] as? String
        likesCount = object["likesCount"] as? Int
        commentsCount = object["commentsCount"] as? Int
    }
    
    class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let media = PFObject(className: "UserMedia")
        
        // Add relevant fields to the object
        media["media"] = getPFFileFromImage(image) // PFFile column type
        media["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        media["caption"] = caption
        media["likesCount"] = 0
        media["commentsCount"] = 0
        
        // Save object (following function will save the object in Parse asynchronously)
        media.saveInBackgroundWithBlock(completion)
    }
    
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    class func processFilesWithArray(array: [UserMedia], completion: () -> ()) {
        let group = dispatch_group_create()
        for media in array {
            if let file = media.mediaFile {
                dispatch_group_enter(group)
                file.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        media.image = UIImage(data: data!)
                    }
                    dispatch_group_leave(group)
                })
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("converted all images")
            completion()
        }
    }
    
    class func mediaWithArray(array: [PFObject]) -> [UserMedia] {
        var media = [UserMedia]()
        
        for object in array {
            media.append(UserMedia(object: object))
        }
        
        return media
    }
}
