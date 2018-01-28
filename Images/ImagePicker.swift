//
//  ImagePicker.swift
//  Images
//
//  Created by Bondar Yaroslav on 29/01/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import AVFoundation
import Photos

/// create for camera
/// create defalt alert
/// create alert sheet

//typealias ResponseImage = (ResponseResult<UIImage>) -> Void
typealias ResponseImage = (_ image: UIImage) -> Void

final class ImagePicker: NSObject {
    
    override init() {
        super.init()
//        controller.sourceType = .photoLibrary
//        controller.delegate = self
    }
    
//    func dismiss() {
//        controller.dismiss(animated: true, completion: nil)
//    }
    
    private var handler: ResponseImage?
    
    func openPicker(in vc: UIViewController, handler: @escaping ResponseImage) {
        self.handler = handler
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        ///picker.modalPresentationStyle = .OverFullScreen

//        struct ImagePickerSettings {
//            var barTintColor : UIColor?
//            var tintColor : UIColor?
//            var barStyle : UIBarStyle?
//        }
        
//        if let settings = settings {
//            if let barTintColor = settings.barTintColor {
//                imagePickerController.navigationBar.barTintColor = barTintColor
//            }
//            if let barStyle = settings.barStyle {
//                imagePickerController.navigationBar.barStyle = barStyle
//            }
//            if let tintColor = settings.tintColor {
//                imagePickerController.view.tintColor = tintColor
//            }
//        }
        
        vc.present(picker, animated: true, completion: nil)
    }
}

extension ImagePicker {
    
    func requestCameraAccess(handler: @escaping (_ status: PhotoManagerAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            handler(.authorized)
        case .denied, .restricted:
            handler(.denied)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    handler(.authorized)
                } else {
                    handler(.denied)
                }
            }
        }
    }
    
    func requestPhotoAccess(handler: @escaping (_ status: PhotoManagerAuthorizationStatus) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            handler(.authorized)
        case .denied, .restricted:
            handler(.denied)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    handler(.authorized)
                case .denied, .restricted:
                    handler(.denied)
                case .notDetermined:
                    /// won't happen but still
                    handler(.denied)
                }
            }
        }
    }
    
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            handler?(image)
            //self.handler?(ResponseResult.success(image))
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            handler?(image)
        } else {
            print("- ImagePicker ERROR: Something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

