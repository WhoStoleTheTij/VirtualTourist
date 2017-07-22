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
    
    var stack: CoreDataHandler! = nil
    var connectionHandler = ConnectionHandler()
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var currentPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(longMapPress(gestureRecogniser:)))
        gestureRecogniser.minimumPressDuration = 1.0
        //gestureRecogniser.delegate = self as! UIGestureRecognizerDelegate
        self.mapView.addGestureRecognizer(gestureRecogniser)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack
        
        self.loadPins()
        // Do any additional setup after loading the view.
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //Mark: handle pin touch
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let point = view.annotation as! MKPointAnnotation
        
        
        //let pin = self.locatePin(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
        
        if self.currentPin != nil {
            let pin = self.currentPin
            self.mapView.deselectAnnotation(point, animated: true)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key:"image", ascending:false)]
            let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin!])
            fetchRequest.predicate = predicate
            
            let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            let photoController: PhotoAlbumViewController
            photoController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            photoController.fetchedResultsController = fc
            
            self.navigationController?.pushViewController(photoController, animated:true)
            
        }else{
            self.mapView.deselectAnnotation(point, animated: true)
            showUserErrorMessage(message: "Oop! Unable to find the correct pin")
        }
        
        
    }
    
    
    //Mark: find and return pin
    func locatePin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Pin?{
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key:"createdAt", ascending:false)]
        
        //using the latitude and logngitude values stored for the pin objects in core data
        let latPredicate = NSPredicate(format: "latitude == %@", argumentArray:[latitude])
        let longPredicate = NSPredicate(format: "longitude == %@", argumentArray:[longitude])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate, longPredicate])
        
        fr.predicate = predicate
        
        if let pins = try? stack.backgroundContext.fetch(fr) as? [Pin]{
            let pin: Pin
            print("PIN - \(pins?.count)")
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
            
            //try? self.stack.context.save()
            
            self.mapView.addAnnotation(annotation)
            print("Just created a pin")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(5 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)){
                
                self.connectionHandler.fetchImagesForLocation(longitude: String(coord.longitude), latitude: String(coord.latitude), pageNumber: 1,completionHandler: { (results, error) in
                    
                    self.stack.performBackgroundBatchOperation({ (workerContext) in
                        let pin = Pin(latitude: Double(coord.latitude), longitude: Double(coord.longitude), context: workerContext)
                        
                        self.currentPin = pin
                        //try? self.stack.backgroundContext.save()
                        
                        for photo in results!{
                            print(photo)
                            if let urlString = photo["url_m"]{
                                
                                let url = URL(string: urlString as! String)
                                if let data = try? Data(contentsOf: url!){
                                    let image = UIImage(data: data)
                                    
                                    let p = Photo(image:(UIImageJPEGRepresentation(image!, 1) as NSData?)!, context: workerContext)
                                    pin.photos?.adding(p)
                                    p.pin = pin
                                    print("PIN -- \(pin.photos?.count)")
                                }
                                
                                
                                
                            }
                            
                        }
                    })
                    
                    
                })
                
                
            }
            try? stack.context.save()
        }
        
        
        
        
    }
    
    //Mark: enable/disable the deletion of pins
    @IBAction func editPinsAction(_ sender: Any) {
    }
    

    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
    
    
    
    
}



