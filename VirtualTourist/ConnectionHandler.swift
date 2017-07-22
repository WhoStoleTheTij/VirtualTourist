//
//  ConnectionHandler.swift
//  VirtualTourist
//
//  Created by Richard H on 15/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import UIKit




class ConnectionHandler: NSObject{
    
    
    override init(){
        super.init()
    }
    
    
    func fetchImagesForLocation(longitude: String, latitude: String, pageNumber: Int ,completionHandler: @escaping (_ results: [AnyObject]?, _ error: String?) -> Void){
        
        if self.isInternetAvailable(){
            let dict = [
                Constants.ParameterKeys.method : Constants.ParameterValues.method,
                Constants.ParameterKeys.apiKey : Constants.ParameterValues.apiKey,
                Constants.ParameterKeys.safeSearch : Constants.ParameterValues.safe,
                Constants.ParameterKeys.extras : Constants.ParameterValues.mediumUrl,
                Constants.ParameterKeys.format : Constants.ParameterValues.responseFormat,
                Constants.ParameterKeys.radius : Constants.ParameterValues.radius,
                Constants.ParameterKeys.longitude : longitude,
                Constants.ParameterKeys.latitude : latitude,
                Constants.ParameterKeys.page : pageNumber,
                Constants.ParameterKeys.noJsonCallback : Constants.ParameterValues.disableJsonCallback,
                Constants.ParameterKeys.pageLimit : Constants.ParameterValues.pageLimit
            ] as [String: AnyObject]
            
            
            var components = URLComponents()
            components.scheme = Constants.Flickr.scheme
            components.host = Constants.Flickr.host
            components.path = Constants.Flickr.path
            components.queryItems = [URLQueryItem]()
            
            for(key, value) in dict{
                let queryItem = URLQueryItem(name:key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
            let request = URLRequest(url: components.url!)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                
                func displayError(_ errorString: String){
                    print(errorString)
                    completionHandler(nil, errorString)
                }
                
                guard (error == nil) else{
                    displayError("Failed to fetch images from Flickr")
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    displayError("The status code was outside the accepted 2xx range")
                    return
                }
                
                guard data != nil else{
                    displayError("The response returned no data")
                    return
                }
                
                let parsedResults: [String:AnyObject]!
                do{
                    parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                    
                    guard let photoArray = parsedResults["photos"] as? [String: AnyObject] else{
                        displayError("There are no photos for your location")
                        return
                    }
                    
                    guard let photos = photoArray["photo"] as? [AnyObject] else{
                        displayError("Thera are no photos for your location")
                        return
                    }
                    
                    completionHandler(photos, nil)
                    
                    
                }catch{
                    displayError("There was an error handling the data from Flickr")
                    return
                }
                
            }
            
            task.resume()

        }else{
            completionHandler(nil, "There is no internet connection")
        }
        
        
        
    }
    
    
    
    //Mark: check the internet is available
    func isInternetAvailable() -> Bool{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.hasInternetConnection()
    }
    
}
