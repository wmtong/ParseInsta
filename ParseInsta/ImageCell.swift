//
//  ImageCell.swift
//  ParseInsta
//
//  Created by William Tong on 3/1/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var instaImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var media: UserMedia! {
        didSet {
            instaImage.image = media.image
            if(media.caption==""){
                descriptionLabel.text = " "
            }else{
            descriptionLabel.text = media.caption
            }
        }
    }

}
