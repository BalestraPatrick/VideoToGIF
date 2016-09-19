//
//  URL+Metadata.swift
//  VideoToGIF
//
//  Created by Patrick Balestra on 9/19/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation

extension URL {
    
    func fileMetadata() -> String {
        let fileManager = FileManager.default
        var fileMetadata = lastPathComponent
        do {
            let fileSize = try fileManager.attributesOfItem(atPath: path)[FileAttributeKey.size] as! NSNumber
            let fileSizeString = ByteCountFormatter().string(fromByteCount: fileSize.int64Value)
            fileMetadata += "\n\(fileSizeString)"
        } catch {}
        return fileMetadata
    }
}
