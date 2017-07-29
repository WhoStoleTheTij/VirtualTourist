//
//  Constants.swift
//  VirtualTourist
//
//  Created by Richard H on 16/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation


struct Constants{
    
    
    struct Flickr{
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
        static let searchBoxHalfWidthHeight = 1.0
        static let searchLatRange = (-90.0, 90.0)
        static let searchLongRante = (-180.0, 180)
    }
    
    struct ParameterKeys{
        static let method = "method"
        static let apiKey = "api_key"
        static let radius = "radius"
        static let extras = "extras"
        static let format = "format"
        static let noJsonCallback = "nojsoncallback"
        static let safeSearch = "safe_search"
        static let latitude = "lat"
        static let longitude = "lon"
        static let page = "page"
        static let pageLimit = "per_page"
    }
    
    struct ParameterValues{
        static let method = "flickr.photos.search"
        static let apiKey = "YOUR_API_KEY"
        static let mediumUrl = "url_m"
        static let safe = "1"
        static let radius = "5"
        static let responseFormat = "json"
        static let disableJsonCallback = "1"
        static let pageLimit = "21"
    }
    
    
    
}
