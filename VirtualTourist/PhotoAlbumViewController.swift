//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Richard H on 15/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var pin: Pin!
    var connectionHandler = ConnectionHandler()
    var messageHelper = MessageHelper()
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionDeleteButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var stack: CoreDataHandler! = nil
    
    var maximumPhotoCount: Int = 21
    
    var photosToDelete: [Int] = []
    var deletingPhotos: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let latitude = CLLocationDegrees(self.pin.latitude)
        let longitude = CLLocationDegrees(self.pin.longitude)
        
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        
        self.mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(coord, span)
        
        self.mapView.region = region
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }

    
    //Mark: loop the collection of memes and display in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.activityView.startAnimating()
        cell.activityView.isHidden = false
        
        var photo: Photo? = nil
        
        if (self.pin.photos?.allObjects.indices.contains(indexPath.row))!{
            photo = self.pin.photos?.allObjects[indexPath.row] as? Photo
        }
        
        cell.setupCell(photo: photo)
        
        return cell
    }
    
    
    //Mark: load the images from Flickr using a random page number
    func loadImages(pageNum: Int){
        
        if !deletingPhotos{
            self.connectionHandler.fetchImagesForLocation(longitude: String(self.pin.longitude), latitude: String(self.pin.latitude), pageNumber: pageNum,completionHandler: { (results, error) in
                
                if error == nil{
                    //set the total page count to allow for random selection later
                    let pageCount = results?["pageCount"]
                    DispatchQueue.main.async {
                        if self.pin.pageCount == 0{
                           self.pin.pageCount = pageCount as! Int16
                        }
                    }
                    
                    
                    
                    let photos = results?["photos"] as! [AnyObject]
                    
                    for photo in photos{
                        if let urlString = photo["url_m"]{
                            DispatchQueue.main.async {
                                let photoItem = Photo(url:urlString as! String, context: self.stack.context)
                                self.pin.photos?.adding(photoItem)
                                photoItem.pin = self.pin
                            }
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }else{
                    self.messageHelper.showUserErrorMessage(message: error!, view: self)
                }
                
                
            })
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.flowLayout.invalidateLayout()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Mark: set the number of items for the collectun view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.pin.photos?.count == 0{
            return maximumPhotoCount
        }else{
            return (self.pin.photos?.count)!
        }
        
    }
    
    
    
    //Mark: set the size of the cells depending on the width of the screen plus the margins
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let dimension = (self.view.frame.size.width - 6.0) / 3.0
        return CGSize(width: dimension, height: dimension)
    }
    
    //Mark: return minimum line spacing - called when layout is invalidated
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(3.0)
    }
    
    //Mark: return minimum interim spacing - called when layout is invalidated
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(3.0)
    }
    
    //Mark: remove the selected image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.imageView.alpha = 0.5
        
        if self.deleteButton.isHidden == true{
            self.deleteButton.isHidden = false
        }
    }
    
    //Mark: deselect a photo
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.imageView.alpha = 1.0
        
        if self.deleteButton.isHidden == false && self.collectionView.indexPathsForSelectedItems!.count == 0{
            self.deleteButton.isHidden = true
        }
    }
    
    //Mark: generate a new list of images
    @IBAction func newCollectionAction(_ sender: Any) {
        
        let pageCount = 4000/21
        
        let pageNum = arc4random_uniform(UInt32(pageCount))
        
        let photos = self.pin.photos?.allObjects as! [Photo]
        self.stack.deletePhotos(photos: photos)
        for photo in photos{
            self.pin.removeFromPhotos(photo)
        }
        
        
        self.loadImages(pageNum: Int(pageNum))

    }

    //Mark: delete the selected cells
    @IBAction func deletePhotoAction(_ sender: Any) {
        while let index = self.collectionView.indexPathsForSelectedItems!.first{
            let photo = self.pin.photos?.allObjects[index.row] as! Photo
            
            self.pin.removeFromPhotos(photo)
            
            self.stack.deletePhotos(photos: [photo])
            self.stack.save()
            
            self.collectionView.deleteItems(at: [index])
        }
    }
    
    
    
}
