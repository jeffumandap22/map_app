//
//  MapVC.swift
//  PixelCity
//
//  Created by Jeffrey Umandap on 06/01/2019.
//  Copyright © 2019 Jeffrey Umandap. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }

    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    
}

extension MapVC: MKMapViewDelegate {
    
}

