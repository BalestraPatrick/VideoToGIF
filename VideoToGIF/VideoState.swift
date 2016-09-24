//
//  VideoState.swift
//  VideoToGIF
//
//  Created by Patrick Balestra on 9/24/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation

enum VideoState {
    case initial
    case selected(url: URL)
    case converting
    case converted(url: URL?)
}
