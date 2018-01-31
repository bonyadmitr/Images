//
//  PermissionsManager.swift
//  Images
//
//  Created by Bondar Yaroslav on 1/31/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import AVFoundation
import Photos

final class PermissionsManager {
    
    func requestCameraAccess(handler: @escaping (_ status: AccessStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            handler(.success)
        case .denied, .restricted:
            handler(.denied)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    handler(.success)
                } else {
                    handler(.denied)
                }
            }
        }
    }
    
    func requestPhotoAccess(handler: @escaping (_ status: AccessStatus) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            handler(.success)
        case .denied, .restricted:
            handler(.denied)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    handler(.success)
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
