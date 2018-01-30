//
//  ImagePicker.swift
//  Images
//
//  Created by Bondar Yaroslav on 29/01/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import AVFoundation
import Photos

/**
add to Info.plist
1) Camera
NSCameraUsageDescription
2) Photo Library
NSPhotoLibraryUsageDescription
Example text:
Please allow access to save photo in your photo library
 */

//typealias ResponseImage = (ResponseResult<UIImage>) -> Void
typealias ResponseImage = (_ image: UIImage) -> Void

enum ImagePickerType {
    case photoLibrary
    case camera
}
extension ImagePickerType {
    var imagePickerType: UIImagePickerControllerSourceType? {
        switch self {
        case .photoLibrary:
            return .photoLibrary
        case .camera:
            return .camera
        }
    }
}

struct ImagePickerSettings {
    let barTintColor: UIColor?
    let tintColor: UIColor?
    let barStyle: UIBarStyle?
}

final class ImagePicker: NSObject {
    
    /// better to use UINavigationBar.appearance() for gloabl customization
    /// use "settings" if need colors besides UINavigationBar.appearance()
    var settings: ImagePickerSettings?
    
    private var handler: ResponseImage?
    
    func openPicker(in vc: UIViewController, for type: ImagePickerType, handler: @escaping ResponseImage) {
        self.handler = handler
        
        guard let imagePickerType = type.imagePickerType else {
            /// open another picker
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(imagePickerType) else {
            return print("- not Available \(imagePickerType)")
        }
        
        let picker = imagePicker(for: imagePickerType)
        vc.present(picker, animated: true, completion: nil)
    }
    
    private func imagePicker(for type: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        //picker.modalPresentationStyle = .OverFullScreen ///???
        setup(picker: picker)
        return picker
    }
    
    private func setup(picker: UIImagePickerController) {
        if let settings = settings {
            let navBar = picker.navigationBar
            
            if let barTintColor = settings.barTintColor {
                navBar.barTintColor = barTintColor
            }
            if let barStyle = settings.barStyle {
                navBar.barStyle = barStyle
            }
            if let tintColor = settings.tintColor {
                navBar.tintColor = tintColor
                navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor]
            }
        }
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
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePicker {
    func openPicker(in vc: UIViewController, handler: @escaping ResponseImage) {
        
        let alertVC = UIAlertController(title: "Choose source", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.requestCameraAccess { [weak self] result in
                guard let `self` = self else { return}
                
                switch result {
                case .authorized:
                    self.openPicker(in: vc, for: .camera) { image in
                        handler(image)
                    }
                case .denied:
                    /// temp
                    presentSettingsAlert(in: vc)
                }
            }
        }
        
        let libraryAction = UIAlertAction(title: "Photo library", style: .default) { _ in
            self.requestPhotoAccess { [weak self] result in
                guard let `self` = self else { return}
                
                switch result {
                case .authorized:
                    self.openPicker(in: vc, for: .photoLibrary) { image in
                        handler(image)
                    }
                case .denied:
                    /// temp
                    presentSettingsAlert(in: vc)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertVC.addAction(cameraAction)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        
        vc.present(alertVC, animated: true, completion: nil)
    }
}
