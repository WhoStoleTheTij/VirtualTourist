//
//  TravelsMapViewController.swift
//  VirtualTourist
//
//  Created by Richard H on 13/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    @IBOutlet weak var deletePinsButton: UIButton!
    
    var stack: CoreDataHandler! = nil
    var connectionHandler = ConnectionHandler()
    var messageHelper = MessageHelper()
    
    var edittingPins: Bool = false
    
    var deletePins: [Pin] = []
    var deleteAnnotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(longMapPress(gestureRecogniser:)))
        gestureRecogniser.minimumPressDuration = 0.2
        //gestureRecogniser.delegate = self as! UIGestureRecognizerDelegate
        self.mapView.addGestureRecognizer(gestureRecogniser)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack
        
        self.loadPins()
        
    }
    
    //Mark: load the pins to the map
    func loadPins(){
        
        if let pins = try? stack.context.fetch(NSFetchRequest(entityName:"Pin")) as? [Pin]{
            var annotations = [MKPointAnnotation]()
            
            for pin in pins!{
                let p = pin
                let lat = CLLocationDegrees(p.latitude)
                let long = CLLocationDegrees(p.longitude)
                
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coord
                
                annotations.append(annotation)
                
            }
            self.mapView.addAnnotations(annotations)
        }
    
    }

    
    ///Mark: handle pin touch
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let point = view.annotation as! MKPointAnnotation
        let pin = self.locatePin(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude, context: self.stack.context)
        if !self.edittingPins{
            //not deleting pins so change screen
            if pin != nil {
                self.mapView.deselectAnnotation(point, animated: true)
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key:"image", ascending:false)]
                let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
                fetchRequest.predicate = predicate
                
                let photoController: PhotoAlbumViewController
                photoController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
                photoController.pin = pin
                
                self.navigationController?.pushViewController(photoController, animated:true)
                
            }else{
                self.mapView.deselectAnnotation(point, animated: true)
                self.messageHelper.showUserErrorMessage(message: "Oop! Unable to find the correct pin", view: self)
            }
        }else{
            //deleting pins
            if pin != nil{
                self.deletePins.append(pin!)
                self.deleteAnnotations.append(point)
            }
        }
        
        
    }
    
    
    //Mark: find and return pin
    func locatePin(latitude: CLLocationDegrees, longitude: CLLocationDegrees, context: NSManagedObjectContext) -> Pin?{
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key:"createdAt", ascending:false)]
        
        //using the latitude and logngitude values stored for the pin objects in core data
        let latPredicate = NSPredicate(format: "latitude == %@", argumentArray:[latitude])
        let longPredicate = NSPredicate(format: "longitude == %@", argumentArray:[longitude])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate, longPredicate])
        
        fr.predicate = predicate
        
        if let pins = try? context.fetch(fr) as? [Pin]{
            let pin: Pin
            if (pins?.count)! > 0{
                pin = (pins?[0])!
                //The correct pin has been found and is returned
                return pin
            }
        }
        return nil
    }
    
    
    
    //Mark: handle the long press and create and save pin
    func longMapPress(gestureRecogniser: UILongPressGestureRecognizer){
        
        if(gestureRecogniser.state == UIGestureRecognizerState.ended){
            let location = gestureRecogniser.location(in: self.mapView)
            let coord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            //only create the pin if it is savable
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            let pin = Pin(latitude: Double(coord.latitude), longitude: Double(coord.longitude), context: self.stack.context)
            
            self.connectionHandler.fetchImagesForLocation(longitude: String(pin.longitude), latitude: String(pin.latitude), pageNumber: 1,completionHandler: { (results, error) in
                
                if error == nil{
                    //set the total page count to allow for random selection later
                    let pageCount = results?["pageCount"]
                    DispatchQueue.main.async {
                        pin.pageCount = pageCount as! Int16
                    }
                    
                    
                    let photos = results?["photos"] as! [AnyObject]
                    
                    for photo in photos{
                        if let urlString = photo["url_m"]{
                            DispatchQueue.main.async {
                                let photoItem = Photo(url:urlString as! String, context: self.stack.context)
                                pin.photos?.adding(photoItem)
                                photoItem.pin = pin
                            }
                            
                        }
                    }
                }else{
                    self.messageHelper.showUserErrorMessage(message: error!, view: self)
                }
                
                
            })
            try? self.stack.context.save()
            self.mapView.addAnnotation(annotation)
        }
    }
    
    //Mark: enable/disable the deletion of pins
    @IBAction func editPinsAction(_ sender: Any) {
        let button = sender as! UIBarButtonItem
        if !edittingPins {
            button.title = "Done"
            self.edittingPins = true
            self.deletePinsButton.isEnabled = true
        }else{
            button.title = "Edit"
            self.edittingPins = false
            self.deletePinsButton.isEnabled = false
        }
    }
    
    
    //Mark: delete the selected pins from the map and remove from storage
    @IBAction func deletePinAction(_ sender: Any) {
        self.mapView.removeAnnotations(self.deleteAnnotations)
        self.stack.deletePin(pins: self.deletePins)
        self.stack.save()
    }
    
}



