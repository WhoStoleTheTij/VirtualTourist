//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Richard H on 15/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: CoreDataViewController{

    var pin: Pin!
    var connectionHandler = ConnectionHandler()
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //@IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        if pin != nil{
            print("There is a pin")
            print(pin.photos?.count)
            
            
            if pin.photos?.count == 0{
                
            }else{
                
            }
            
            
            
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //Mark: loop the collection of memes and display in the collection view
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        let image = UIImage(data: photo.image! as Data)
        print(photo)
        cell.imageView?.image = image
        // Configure the cell
        
        return cell
    }

}
