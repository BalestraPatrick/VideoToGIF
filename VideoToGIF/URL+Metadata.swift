//
//  URL+Metadata.swift
//  VideoToGIF
//
//  Created by Patrick Balestra on 9/19/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation
import AVFoundation

extension URL {

    /// Creates a string containing some basic metadata for the given URL video.
    ///
    /// - returns: A string with the filename and correctly formatted filesize.
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

    /// Finds out the duration for the given URL video.
    ///
    /// - returns: The duration of the video.
    func videoDuration() -> Float {
        let videoAssetDuration = AVURLAsset(url: self).duration
        let videoDuration = Float(CMTimeGetSeconds(videoAssetDuration))
        return videoDuration
    }
}
