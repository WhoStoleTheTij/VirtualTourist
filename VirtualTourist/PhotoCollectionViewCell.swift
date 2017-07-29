//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Richard H on 16/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    //Mark: setup the image cell
    func setupCell(photo: Photo?){
        
        if photo != nil{
            self.imageView.image = UIImage(data: (photo?.image)! as Data)
            self.activityView.isHidden = true
            self.activityView.stopAnimating()
        }
    }
}
