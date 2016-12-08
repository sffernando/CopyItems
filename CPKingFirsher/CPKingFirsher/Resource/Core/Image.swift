//
//  Image.swift
//  CPKingFirsher
//
//  Created by koudai on 2016/12/8.
//  Copyright © 2016年 fernando. All rights reserved.
//

import Foundation


#if os(macOS)
    import AppKit
    private var imagesKey: Void?
    private var durationKey: Void?
#else
    import UIKit
    import MobileCoreServices
    private var imageSourceKey: Void?
    private var animatedImageDataKey: Void?
#endif

import ImageIO
import CoreGraphics

#if !os(watchOS)
    import Accelerate
    import CoreImage
#endif

// MARK: image properties
extension KingFisher where Base: Image {
    #if os(macOS)
    var cgImage: CGImage? {
        return base.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    var scale: CFloat {
        return 1.0
    }
    
    fileprivate(set) var images: [Image]? {
        get {
            return objc_getAssociatedObject(base, &imagesKey) as? [Image]
        }
        set {
            objc_setAssociatedObject(base, &imagesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate(set) var duration: TimeInterval {
        get {
            objc_getAssociatedObject(base, &durationKey) as? TimeInterval ?? 0.0
        }
        set {
            objc_setAssociatedObject(base, &durationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var size: CGSize {
        return base.representations.reduce(CGSize.zero, { size, rep in
            return CGSize(width: max(size.width, CGFloat(rep.pixelsWide)), height: max(size.height, CGFloat(rep.pixelsHigh)))
        })
    }
    #else
    var cgImage: CGImage? {
        return base.cgImage
    }
    
    var scale: CGFloat {
        return base.scale
    }
    
    var images: [Image]? {
        return base.images;
    }
    
    var duration: TimeInterval {
        return base.duration
    }

    fileprivate(set) var imageSource: ImageSource? {
        get {
            return objc_getAssociatedObject(base, &imageSourceKey) as? ImageSource
        }
        set {
            objc_setAssociatedObject(base, &imageSourceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate(set) var animatedImageData: Data? {
        get {
            return objc_getAssociatedObject(base, &animatedImageDataKey) as? Data
        }
        set {
            objc_setAssociatedObject(base, &animatedImageDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var size: CGSize {
        return base.size
    }
    #endif
}
