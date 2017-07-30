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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionDeleteButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var stack: CoreDataHandler! = nil
    
    var maximumPhotoCount: Int = 21
    
    var imageCollection:[Photo] = []
    
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
        
        if self.pin.photos?.count == 0{
            self.loadImages(pageNum: 1)
        }else{
            self.imageCollection = self.pin.photos?.allObjects as! [Photo]
        }
        
    }

    
    //Mark: loop the collection of memes and display in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        var photo: Photo? = nil
        
        if self.imageCollection.count > 0 && self.imageCollection.indices.contains(indexPath.row){
            photo = self.imageCollection[indexPath.row]
        }
        
        if indexPath.row <= self.imageCollection.count && !deletingPhotos{
            cell.activityView.startAnimating()
            cell.isHidden = false
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
                    self.pin.pageCount = pageCount as! Int16
                    
                    let photos = results?["photos"] as! [AnyObject]
                    
                    for photo in photos{
                        if let urlString = photo["url_m"]{
                            
                            let url = URL(string: urlString as! String)
                            if let data = try? Data(contentsOf: url!){
                                let image = UIImage(data: data)
                                //
                                let photoItem = Photo(image:(UIImageJPEGRepresentation(image!, 1) as NSData?)!, url:urlString as! String, context: self.stack.context)
                                self.pin.photos?.adding(photoItem)
                                photoItem.pin = self.pin
                                self.imageCollection = self.pin.photos?.allObjects as! [Photo]
                                
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }else{
                    self.showUserErrorMessage(message: error!)
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
        var returnValue = maximumPhotoCount
        if self.pin.photos?.count != 0{
            returnValue = (self.pin.photos?.count)!
        }
        return returnValue
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
        
        var pageCount = self.pin.pageCount
        if pageCount == 0{
            pageCount = 1
        }
        let photos = self.pin.photos?.allObjects as! [Photo]
        
        self.stack.deletePhotos(photos: photos)
        var pageNum: Int
        if pageCount == 0{
            pageNum = 1
        }else{
            pageNum = Int(arc4random_uniform(UInt32(pageCount)))
        }
        self.loadImages(pageNum: pageNum)

    }

    //Mark: delete the selected cells
    @IBAction func deletePhotoAction(_ sender: Any) {
        while let index = self.collectionView.indexPathsForSelectedItems!.first{
            let photo = self.imageCollection[index.row]
            self.stack.deletePhotos(photos: [photo])
            self.stack.save()
            self.imageCollection.remove(at: index.row)
            self.collectionView.deleteItems(at: [index])
        }
    }
    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
    
}
