//
//  PhotoInfo.swift
//  PixelCity
//
//  Created by Jeffrey Umandap on 07/01/2019.
//  Copyright © 2019 Jeffrey Umandap. All rights reserved.
//


import Foundation

struct PhotoInfo {
    
    var id: Any!
    var owner: Any!
    var secret: Any!
    var server: Any!
    var farm: Any!
    var title: Any!
    var ispublic: Any!
    var isfriend: Any!
    var isfamily: Any!
    var url: String
    var image: UIImage?
    
    init(id: Any, owner: Any, secret: Any, server: Any, farm: Any, title: Any, ispublic: Any, isfriend: Any, isfamily: Any, url: String) {
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.ispublic = ispublic
        self.isfriend = isfriend
        self.isfamily = isfamily
        self.url = url
    }
}

import UIKit
extension PhotoInfo {
    func addImage(photo: PhotoInfo, image: UIImage) -> PhotoInfo {
        var photo = PhotoInfo.init(id: id, owner: owner, secret: secret, server: server, farm: farm, title: title, ispublic: ispublic, isfriend: isfriend, isfamily: isfamily, url: url)
        photo.image = image
        return photo
    }
}
