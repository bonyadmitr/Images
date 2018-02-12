//
//  PhotoViewerController.swift
//  Images
//
//  Created by Bondar Yaroslav on 10/02/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit
import Photos


import MobileCoreServices

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
                
                if let ciImage = CIImage(data: data) {
                    print(ciImage.properties)
                }
                
                
                let qqq = NSMutableDictionary()
                qqq["1111111111111111111"] = "1111111111111111111"
                let path = (info?["PHImageFileURLKey"] as? URL)!
                
                
                let qdata = NSMutableData(data: data)
                
                let z = self.saveImage(qdata, withMetadata: qqq, atPath: path)
                print(z)
                print(CIImage(data: qdata as Data)?.properties ?? "nil")
                print()
                
                
            }
        }
        
        
        
        
//        let options = PHContentEditingInputRequestOptions()
//        options.networkAccessAllowed = true //download asset metadata from iCloud if needed
//
//        asset.requestContentEditingInputWithOptions(options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
//            let fullImage = CIImage(contentsOfURL: contentEditingInput!.fullSizeImageURL)
//
//            print(fullImage.properties)
//        }
    }
    
    
    @IBAction func actionClearBarButton(_ sender: UIBarButtonItem) {
    
        
        
    }
    
    private func clearMetadata() {
        guard let asset = asset else {
            return
        }
        
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        // Load metadata for asset:
        asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
            guard
                let url = contentEditingInput!.fullSizeImageURL,
                let fullImage = CIImage(contentsOf: url)
            else {
                return
            }
            
            
            
            let resources = PHAssetResource.assetResources(for: asset)
            guard let avAsset = resources.first else {
                return
            }
            
//            guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else { return }
//
//            var mutableMetadata = exportSession.asset.metadata
//            let metadataCopy = mutableMetadata

            
//            fullImage.properties = [:]
            
            
            
//            var date: NSDate? = nil
//            // Parse the date from the EXIF data:
//            if let dateTimeString = fullImage!.properties["{Exif}"]?["DateTimeOriginal"] as? String {
//                date = xifDateFormatter.dateFromString(dateTimeString)
//            }
//            // Parse the 2D location from the GPS data:
//            var location: CLLocation? = nil
//            if let gps = fullImage?.properties["{GPS}"] {
//                var latitude: CLLocationDegrees? = nil
//                if let latitudeRaw = gps["Latitude"] as? CLLocationDegrees, latitudeRef = gps["LatitudeRef"] as? String {
//                    let sign = ((latitudeRef == "N") ? 1 : -1)
//                    latitude = CLLocationDegrees(Double(sign) * Double(latitudeRaw))
//                }
//                var longitude: CLLocationDegrees? = nil
//                if let longitudeRaw = gps["Longitude"] as? CLLocationDegrees, longitudeRef = gps["LongitudeRef"] as? String {
//                    let sign = ((longitudeRef == "E") ? 1 : -1)
//                    longitude = CLLocationDegrees(Double(sign) * Double(longitudeRaw))
//                }
//                if latitude != nil && longitude != nil {
//                    location = CLLocation(latitude: latitude!, longitude: longitude!)
//                }
//            }
//            self.captionPhoto(ImageWithMeta(photo: photo, location: location, date: date))
        }

    }
    
    
    
    
    ///https://developer.apple.com/library/content/qa/qa1895/_index.html
    ///https://gist.github.com/kwylez/a4b6ec261e52970e1fa5dd4ccfe8898f
    
    /// Generate Metadata Exif for GPS
    ///https://gist.github.com/nitrag/343fe13f01bb0ef3692f2ae2dfe33e86
    
    /// parse location
    /// https://gist.github.com/kkleidal/73401405f7d5fd168d061ad0c154ea18
    
    
    
    /// https://stackoverflow.com/a/42818232
    func saveImage(_ data: NSMutableData, withMetadata metadata: NSMutableDictionary, atPath path: URL) -> Bool {
//        guard let jpgData = UIImageJPEGRepresentation(image, 1) else {
//            return false
//        }
        // make an image source
        guard let source = CGImageSourceCreateWithData(data as CFData, nil), let uniformTypeIdentifier = CGImageSourceGetType(source) else {
            return false
        }
        
        
        
        // make an image destination pointing to the file we want to write
        guard let destination = CGImageDestinationCreateWithData(data, uniformTypeIdentifier, 1, nil) else {
            return false
        }
        
        // add the source image to the destination, along with the metadata
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata)
        
        // and write it out
        return CGImageDestinationFinalize(destination)
    }

    
    /// https://medium.com/@emiswelt/exporting-images-with-metadata-to-the-photo-gallery-in-swift-3-ios-10-66210bbad5d2
    ///
    // Take care when passing the paths. The directory must exist.
    // let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
    // let filePath = path + name + ".jpg"
    // try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    // saveToPhotoAlbumWithMetadata(image, filePath: filePath)
    static func saveToPhotoAlbumWithMetadata(_ image: CGImage, filePath: String) {
        
        let cfPath = CFURLCreateWithFileSystemPath(nil, filePath as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        
        // You can change your exif type here.
        let destination = CGImageDestinationCreateWithURL(cfPath!, kUTTypeJPEG, 1, nil)
        
        // Place your metadata here.
        // Keep in mind that metadata follows a standard. You can not use custom property names here.
        let tiffProperties = [
            kCGImagePropertyTIFFMake as String: "Your camera vendor",
            kCGImagePropertyTIFFModel as String: "Your camera model"
            ] as CFDictionary
        
        let properties = [
            kCGImagePropertyExifDictionary as String: tiffProperties
            ] as CFDictionary
        
        CGImageDestinationAddImage(destination!, image, properties)
        CGImageDestinationFinalize(destination!)
        
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
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
