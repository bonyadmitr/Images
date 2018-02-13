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
/// PHAdjustmentData

final class PhotoViewerController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageScrollView: ImageScrollView!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    var asset: PHAsset?
    private var requestID: PHImageRequestID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        progressView.progress = 0
        imageScrollView.delegate = self
        
        updateStillImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.updateZoom()
    }
    
    deinit {
        print("- deinit PhotoViewerController")
        /// optimization for big images
        if let requestID = requestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func updateStillImage() {
        guard let asset = asset else {
            return
        }
        
        favoriteBarButton.title = asset.isFavorite ? "♥︎" : "♡"
        
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
        //progressView.progress = 0 /// need?
        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options,
            resultHandler: { image, info in
                /// Hide the progress view now the request has completed.
                self.progressView.isHidden = true
                
                guard let image = image else {
                    return
                }
                self.imageScrollView.image = image
                self.imageScrollView.updateZoom()
        })
        
        
        printSize()
        //printMetadata()
    }
    
    func printSize() {
        guard let asset = asset else {
            return
        }
        
        print("creationDate", asset.creationDate ?? "nil")
        print("modificationDate", asset.modificationDate ?? "nil")
        print(asset.originalFilename ?? "originalFilename nil")
        print(asset.location ?? "location nil")
        
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        //options.isSynchronous = true
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, uniformTypeIdentifier, orientation, info) in
            if let data = data {
                print(data.sizeString)
                
                if let fileName = PHAsset.filename(from: info) {
                    print("iOS fileName", fileName)
                }
                
                /// metadata
//                if let ciImage = CIImage(data: data) {
//                    print(ciImage.properties)
//                }

            }
        }
    }
    
    @IBAction func actionDeleteBarButton(_ sender: UIBarButtonItem) {
        removeAsset()
    }
    
    @IBAction func actionFavoriteBarButton(_ sender: UIBarButtonItem) {
        toggeleFavoriteAsset()
    }
    
    private func printMetadata() {
        guard let asset = asset else {
            return
        }
        
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        
        asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
            guard
                let url = contentEditingInput?.fullSizeImageURL,
                let fullImage = CIImage(contentsOf: url)
            else {
                return
            }
            print(fullImage.properties)
        }

    }
    
    func toggeleFavoriteAsset() {
        print("self.asset 1", self.asset?.isFavorite == true ? "♥︎" : "♡")
        
        guard let asset = asset else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = !asset.isFavorite
            request.creationDate = Date()
//            request.isHidden = !asset.isHidden
            request.location = nil
        }, completionHandler: { success, error in
            if success {
                DispatchQueue.main.sync {
                    print("self.asset 2", self.asset?.isFavorite == true ? "♡": "♥︎")
                    print("asset", asset.isFavorite ? "♡": "♥︎")
                    self.favoriteBarButton.title = asset.isFavorite ? "♡": "♥︎"
                }
            } else if let error = error {
                print("can't set favorite: \(error.localizedDescription)")
            } else {
                print(CustomErrors.unknown())
            }
        })
        
    }
    
    func removeAsset() {
        /// https://developer.apple.com/documentation/photos/phassetcollection
        guard let asset = asset else {
            return
        }
        
        let completion = { (success: Bool, error: Error?) -> Void in
            if success {
                print("deleted asset")
                /// check !!!!!
//                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                DispatchQueue.main.sync {
                    _ = self.navigationController!.popViewController(animated: true)
                }
            } else if let error = error {
                print("can't remove asset: \(error.localizedDescription)")
            } else {
                print(CustomErrors.unknown())
            }
        }
        
        let fetchResult = PHAssetCollection.fetchAssetCollectionsContaining(asset, with: .smartAlbum, options: nil)
        
        if fetchResult.count == 0 {
            // Delete asset from library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: completion)
            
        } else {
            /// add DispatchGroup handler !!!
            fetchResult.enumerateObjects { (collection, _, _) in
                // Remove asset from album
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCollectionChangeRequest(for: collection)
                    request?.removeAssets([asset] as NSArray)
                }, completionHandler: completion)
            }
        }

    }
    
    
    func applyPhotoFilter(_ filterName: String, input: PHContentEditingInput, output: PHContentEditingOutput, completion: () -> Void) {
        
        // Load the full size image.
        guard let inputImage = CIImage(contentsOf: input.fullSizeImageURL!)
            else { fatalError("can't load input image to edit") }
        
        // Apply the filter.
        let outputImage = inputImage
            .oriented(forExifOrientation: input.fullSizeImageOrientation)
            .applyingFilter(filterName, parameters: [:])
        
        // Write the edited image as a JPEG.
        
            if #available(iOS 10.0, *) {
                do {
                    try CIContext().writeJPEGRepresentation(of: outputImage,
                                                            to: output.renderedContentURL,
                                                            colorSpace: inputImage.colorSpace!,
                                                            options: [:])
                } catch let error {
                    fatalError("can't apply filter to image: \(error)")
                }
            } else {
                /// TODO
//                let context = UIGraphicsGetCurrentContext()!
//                context.
            }

        completion()
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
                let details = changeInstance.changeDetails(for: asset)
            else {
                return
            }
            
            guard let assetAfterChanges = details.objectAfterChanges else {
                print("Photo was deleted")
                _ = self.navigationController!.popViewController(animated: true)
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
