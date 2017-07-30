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
    
    var connectionHandler = ConnectionHandler()
    
    //Mark: setup the image cell
    func setupCell(photo: Photo?){
        
        if photo != nil && photo?.url != nil{
            
            if photo?.image == nil{
                self.connectionHandler.fetchImageData(urlString: (photo?.url)!, completionHandler: { (data, error) in
                    
                    if error == nil{
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data! as Data)
                            photo?.image = data! as NSData
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                        }
                        
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        delegate.stack.save()
                    }else{
                        self.imageView.image = UIImage(named: "defaultImage")
                    }
                    
                })
            }else{
                let p = photo?.image
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: p! as Data)
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                }
                
            }
            
            
        }
    }
}
