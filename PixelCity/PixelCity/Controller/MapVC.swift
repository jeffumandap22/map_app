//
//  MapVC.swift
//  PixelCity
//
//  Created by Jeffrey Umandap on 06/01/2019.
//  Copyright © 2019 Jeffrey Umandap. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner : UIActivityIndicatorView?
    var progressLabel : UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    
    //var imageUrlArray = [String]()
    //var imageArray = [UIImage]()
    
    var photoService = PhotoService.instance
    var photoInfoArray = [PhotoInfo]()
    var photo: PhotoInfo!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if collectionView != nil {
            pullUpView.addSubview(collectionView!)
        }
        registerForPreviewing(with: self, sourceView: collectionView!)
        
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancellAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLabel?.textAlignment = .center
        //progressLabel?.text = "Testing..."
        collectionView?.addSubview(progressLabel!)
    }
    
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    func getFlickrInfo(forAnnotation annotation: DroppablePin) -> String {
        return "\(FLICKR_URL)&content_type=1&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=\(regionRadius/1000)&per_page=\(NUMBER_OF_PHOTOS_TO_SHOW)&format=json&nojsoncallback=1"
    }

    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLabel()
        cancellAllSessions()
        
        //imageUrlArray = []
        //imageArray = []
        
        photoInfoArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLabel()
    
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        print(flickrURL(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40))
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let alamofireUrl = getFlickrInfo(forAnnotation: annotation)
        
        photoService.getphotoInfoArray(forUrl: alamofireUrl) { (finished) in
            
            if finished {
                self.photoInfoArray = self.photoService.photoInfoArray
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        print(self.photoInfoArray)
                        self.removeSpinner()
                        self.removeProgressLabel()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    
    func retrieveImages(handler: @escaping(_ status: Bool) -> ()) {
        var newPhotoInfoArray = [PhotoInfo]()
        for photo in photoInfoArray {
            
            Alamofire.request(photo.url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                let updatedPhoto = photo.addImage(photo: photo, image: image)
                newPhotoInfoArray.append(updatedPhoto)
                self.progressLabel?.text = "\(newPhotoInfoArray.count)/\(NUMBER_OF_PHOTOS_TO_SHOW) Images Downloaded"
                
                if newPhotoInfoArray.count == self.photoInfoArray.count {
                    print(newPhotoInfoArray)
                    self.photoInfoArray = newPhotoInfoArray
                    handler(true)
                }
            })
        }
    }
    
    func cancellAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoInfoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell {
            let imageFromIndex = photoInfoArray[indexPath.row]
            let imageView = UIImageView(image: imageFromIndex.image)
            cell.addSubview(imageView)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        let selectedPhoto = photoInfoArray[indexPath.row]
        popVC.initData(forImage: selectedPhoto)
        present(popVC, animated: true, completion: nil)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil }
        
        let photo = photoInfoArray[indexPath.row]
        popVC.initData(forImage: photo)
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

