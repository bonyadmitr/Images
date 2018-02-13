//
//  PHAsset+Properties.swift
//  Images
//
//  Created by Bondar Yaroslav on 13/02/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import Photos

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

extension PHAsset {
    static func filename(from info: [AnyHashable : Any]?) -> String? {
        return (info?["PHImageFileURLKey"] as? URL)?.lastPathComponent
    }
}
