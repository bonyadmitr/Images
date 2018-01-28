//
//  ViewController.swift
//  Images
//
//  Created by Bondar Yaroslav on 28/01/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var imagePicker = ImagePicker()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var pickPhotoButton: UIButton! {
        didSet {
            ///IB buttonType = .custom
            pickPhotoButton.setTitle("Pick photo", for: .normal)
            pickPhotoButton.setTitleColor(UIColor.white, for: .normal)
            pickPhotoButton.setTitleColor(UIColor.white.darker(), for: .highlighted)
            pickPhotoButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
            pickPhotoButton.setBackgroundColor(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), for: .normal)
            pickPhotoButton.setBackgroundColor(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1).darker(), for: .highlighted)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func actionPickPhotoButton(_ sender: UIButton) {
        imagePicker.requestPhotoAccess { [weak self] result in
            guard let `self` = self else { return}
            
            switch result {
            case .authorized:
                /// openPhoto
                /// openCamera ???
                /// openCameraPicker ???
                self.imagePicker.openPicker(in: self) { [weak self] image in
                    guard let `self` = self else { return}
                    self.photoImageView.image = image
                }
            case .denied:
                print("denied")
                break
            }
        }
    }
}
