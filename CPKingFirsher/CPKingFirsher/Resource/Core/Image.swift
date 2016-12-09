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

// MARK: Image Conversion

extension KingFisher where Base: Image {
    #if os(macOS)
    static func image(cgImage: CGImage, scale: CGFloat, refImage: Image?) -> Image {
        return Image(cgImage: cgImage, size: CGSize.zero)
    }
    
    /**
     Normalize the image. This method does nothing in OS X.
     - returns: The image itself.
     */
    public var normalized: Image {
        return base
    }
    
    static func animated(with images: [Image], forDuration forDurationduration: TimeInterval) -> Image? {
        return nil
    }
    #else
    static func image(cgImage: CGImage, scale: CGFloat, refImage: Image?) -> Image {
        if let refImage = refImage {
            return Image(cgImage: cgImage, scale: scale, orientation: refImage.imageOrientation)
        } else {
            return Image(cgImage: cgImage, scale: scale, orientation: .up)
        }
    }

    /**
     Normalize the image. This method will try to redraw an image with orientation and scale considered.
     - returns: The normalized image with orientation set to up and correct scale
     */
    public var normalized: Image {
        // prevent animated image (GIF) lose it's images
        guard images == nil else {
            return base
        }
        
        // no need to do anything if already up
        guard base.imageOrientation != .up else {
            return base
        }
        
        return draw(cgImage: nil, to: size) {
            base.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
    }
    
    static func animated(with images: [Image], forDuration duration: TimeInterval) -> Image? {
        return .animatedImage(with: images, duration: duration)
    }
    
    #endif
}



extension CGBitmapInfo {
    var fixed: CGBitmapInfo {
        var fixed = self
        let alpha = (rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
        if alpha == CGImageAlphaInfo.none.rawValue {
            fixed.remove(.alphaInfoMask)
            fixed = CGBitmapInfo(rawValue: fixed.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
        } else if !(alpha == CGImageAlphaInfo.noneSkipFirst.rawValue) || !(alpha == CGImageAlphaInfo.noneSkipLast.rawValue) {
            fixed.remove(.alphaInfoMask)
            fixed = CGBitmapInfo(rawValue: fixed.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        }
        return fixed
    }
}


extension KingFisher where Base: Image {
    
    func draw(cgImage: CGImage?, to size: CGSize, draw: ()->()) -> Image {
        #if os(macOS)
            guard let rep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(size.width),
                pixelsHigh: Int(size.height),
                bitsPerSample: cgImage?.bitsPerComponent ?? 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: NSCalibratedRGBColorSpace,
                bytesPerRow: 0,
                bitsPerPixel: 0) else
            {
                assertionFailure("[Kingfisher] Image representation cannot be created.")
                return base
            }
            rep.size = size
            
            NSGraphicsContext.saveGraphicsState()
            
            let context = NSGraphicsContext(bitmapImageRep: rep)
            NSGraphicsContext.setCurrent(context)
            draw()
            NSGraphicsContext.restoreGraphicsState()
            
            let outputImage = Image(size: size)
            outputImage.addRepresentation(rep)
            return outputImage
        #else
            
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            draw()
            return UIGraphicsGetImageFromCurrentImageContext() ?? base
            
        #endif
    }
    
    #if os(macOS)
    func fixedForRetinaPixel(cgImage: CGImage, to size: CGSize) -> Image {
    
    let image = Image(cgImage: cgImage, size: base.size)
    let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
    
    return draw(cgImage: cgImage, to: self.size) {
    image.draw(in: rect, from: NSRect.zero, operation: .copy, fraction: 1.0)
    }
    }
    #endif
}


extension CGContext {
    static func createARGBContext(from imageRef: CGImage) -> CGContext? {
        
        let w = imageRef.width
        let h = imageRef.height
        let bytesPerRow = w * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let data = malloc(bytesPerRow * h)
        defer {
            free(data)
        }
        
        let bitmapInfo = imageRef.bitmapInfo.fixed
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here.
        return CGContext(data: data,
                         width: w,
                         height: h,
                         bitsPerComponent: imageRef.bitsPerComponent,
                         bytesPerRow: bytesPerRow,
                         space: colorSpace,
                         bitmapInfo: bitmapInfo.rawValue)
    }
}

extension Double {
    var isEven: Bool {
        return truncatingRemainder(dividingBy: 2.0) == 0
    }
}

















