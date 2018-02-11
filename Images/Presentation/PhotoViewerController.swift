//
//  PhotoViewerController.swift
//  Images
//
//  Created by Bondar Yaroslav on 10/02/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit
import Photos

/// need send image or imageView for long downloads

final class PhotoViewerController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var asset: PHAsset?
    private var requestID: PHImageRequestID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progress = 0
        imageScrollView.delegate = self
        
        
        /// update asset
        /// https://developer.apple.com/documentation/photos/phassetcollection
//        guard let asset = asset else {
//            return
//        }
//        let fetchResult = PHAssetCollection.fetchAssetCollectionsContaining(asset, with: .smartAlbum, options: nil)
//        guard let collecttion = fetchResult.firstObject else {
//            return
//        }
//        collecttion.estimatedAssetCount
        
        

        
        
        updateStillImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.updateZoom()
    }
    
    deinit {
        if let requestID = requestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func updateStillImage() {
        guard let asset = asset else {
            return
        }
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        //options.isSynchronous = true
        
        /// for iCloud only
        /// Handler might not be called on the main queue, so re-dispatch for UI work.
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        progressView.isHidden = false
        //progressView.progress = 0 ///???
        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options,
            resultHandler: { image, info in
                // Hide the progress view now the request has completed.
                self.progressView.isHidden = true
                
                // If successful, show the image view and display the image.
                guard let image = image else { return }
                
                // Now that we have the image, show it.
                
                self.imageScrollView.image = image
                self.imageScrollView.updateZoom()
                
        })
        
        
        printSize()
    }
    
    func printSize() {
        guard let asset = asset else {
            return
        }
        
        print("creationDate", asset.creationDate ?? "nil")
        print("modificationDate", asset.modificationDate ?? "nil")
        print(asset.originalFilename ?? "originalFilename nil")
        
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
//        options.isSynchronous = true
        options.resizeMode = .exact
        ///PHImageFileURLKey
        
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, uniformTypeIdentifier, orientation, info) in
            if let data = data {
                print(data.sizeString)
                
                if let fileName = (info?["PHImageFileURLKey"] as? URL)?.lastPathComponent {
                    print("///////" + fileName + "////////")
                    //do sth with file name
                }
            }
        }
    }
}

extension PhotoViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageScrollView.adjustFrameToCenter()
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension PhotoViewerController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Call might come on any background queue. Re-dispatch to the main queue to handle it.
        DispatchQueue.main.sync {
            // Check if there are changes to the asset we're displaying.
            guard
                let asset = asset,
                let details = changeInstance.changeDetails(for: asset),
                let assetAfterChanges = details.objectAfterChanges
            else {
                return
            }

            // Get the updated asset.
            self.asset = assetAfterChanges

            // If the asset's content changed, update the image // and stop any video playback.
            if details.assetContentChanged {
                updateStillImage()
            }
        }
    }
}

extension Data {
    static let byteFormatter = ByteCountFormatter().setup {
        $0.allowedUnits = .useAll
        $0.countStyle = .file
    }
    
    var sizeString: String {
        return Data.byteFormatter.string(fromByteCount: Int64(count))
    }
}

extension PHAsset {
    var originalFilename: String? {
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            return resources.first?.originalFilename
        } else {
            /// this is an undocumented workaround that works as of iOS 9.1
            return value(forKey: "filename") as? String
        }
    }
}
