//
//  NSProgressIndicator+Convenience.swift
//  VideoToGIF
//
//  Created by Patrick Balestra on 9/23/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import AppKit

extension NSProgressIndicator {

    func start() {
        isHidden = false
        startAnimation(nil)
    }

    func stop() {
        isHidden = true
        stopAnimation(nil)
    }
}
