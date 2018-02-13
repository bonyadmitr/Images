//
//  Data+Size.swift
//  Images
//
//  Created by Bondar Yaroslav on 13/02/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import Foundation

extension Data {
    var sizeString: String {
        return ByteCountFormatter().setup {
            $0.allowedUnits = .useAll
            $0.countStyle = .file
        }.string(fromByteCount: Int64(count))
    }
}
