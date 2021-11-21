//
//  ZoomView+Constants.swift
//  Camera
//
//  Created by Zheng on 11/20/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct C {
    static var edgePadding = CGFloat(0)
    static var zoomFactorLength = CGFloat(80)
    static var spacing = CGFloat(0)
    
    static let minZoom = CGFloat(0.5)
    static let maxZoom = CGFloat(10)
    
    static let activationStartDistance = CGFloat(0.12)
    static let activationRange = CGFloat(0.05)
    
    static let zoomFactors = [
        ZoomFactor(zoomRange: minZoom...1, positionRange: 0...0.25),
        ZoomFactor(zoomRange: 1.nextUp...2, positionRange: 0.25.nextUp...0.5),
        ZoomFactor(zoomRange: 2.nextUp...maxZoom, positionRange: 0.5.nextUp...1),
    ]
}

struct ZoomFactor: Hashable {
    
    /// range of zoom
    /// example: `0.5..<1`
    var zoomRange: ClosedRange<CGFloat>
    
    /// position relative to entire slider
    /// example: `0.0..<0.25`
    var positionRange: ClosedRange<CGFloat>
    
    /// how wide `positionRange` normally is
    static let normalPositionRange = 0.25
}
