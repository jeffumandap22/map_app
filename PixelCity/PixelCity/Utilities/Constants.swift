//
//  Constants.swift
//  PixelCity
//
//  Created by Jeffrey Umandap on 07/01/2019.
//  Copyright © 2019 Jeffrey Umandap. All rights reserved.
//

import Foundation

let API_KEY = "76e1cf31730aed1be38610f7344ec700"

func flickrURL(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}



