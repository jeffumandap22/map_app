//
//  PopVC.swift
//  PixelCity
//
//  Created by Jeffrey Umandap on 07/01/2019.
//  Copyright © 2019 Jeffrey Umandap. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoCredit: UILabel!
    
    var passedImage: PhotoInfo!
    
    
    func initData(forImage image: PhotoInfo) {
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popImageView.image = passedImage.image
        titleLabel.text = passedImage.title as? String
        photoCredit.text = "Photo credit: \(passedImage.owner as! String)"
        addDoubleTap()
    }

    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
}
