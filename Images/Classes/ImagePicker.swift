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

/// openPhoto
/// openCamera ???
/// openCameraPicker ???

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
        
        return picker
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

