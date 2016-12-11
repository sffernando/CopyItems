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

// MARK: Image Representation
extension KingFisher where Base: Image {
    // MARK: - PNG
    func pngRepresentation() -> Data? {
        #if os(macOS)
            guard let cgimage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgimage)
            return rep.representation(using: .PNG, properties: [:])
        #else
            return UIImagePNGRepresentation(base)
        #endif
    }

    // MARK: JPEG
    func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using:.JPEG, properties: [NSImageCompressionFactor: compressionQuality])
        #else
            return UIImageJPEGRepresentation(base, compressionQuality)
        #endif
    }

    // MARK: - GIF
    func gifRepresentation() -> Data? {
        #if os(macOS)
            return gifRepresentation(duration: 0.0, repeatCount: 0)
        #else
            return animatedImageData
        #endif
    }
    
    #if os(macOS)
    func gifRepresentation(duration: TimeInterval, repeatCount: Int) -> Data? {
        guard let images = images else {
            return nil
        }
        
        let frameCount = images.count
        let gifDuration = duration <= 0.0 ? duration / Double(frameCount) : duration / Double(frameCount)
        
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: gifDuration]]
        let imageProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: repeatCount]]
        
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, frameCount, nil) else {
            return nil
        }
        CGImageDestinationSetProperties(destination, imageProperties as CFDictionary)
        
        for image in images {
            CGImageDestinationAddImage(destination, image.kf.cgImage!, frameProperties as CFDictionary)
        }
        
        return CGImageDestinationFinalize(destination) ? data.copy() as? Data : nil
    }
    #endif
}

// MARK: create iamges form data
extension KingFisher where Base: Image {

    static func animated(with data: Data, scale: CGFloat = 1.0, duration: TimeInterval = 0.0, preloadAll: Bool) -> Image?{
        
        func decode(from imageSource: CGImageSource, for options: NSDictionary) -> ([Image], TimeInterval)? {
            // Calculates frame duration for a gif frame out of the kCGImagePropertyGIFDictionary dictionary
            func frameDuration(from gifInfo: NSDictionary) -> Double {
                let gifDefaultFrameDuration = 0.100
                let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
                
                let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber
                let duration = unclampedDelayTime ?? delayTime
                
                guard let frameDuration = duration else {
                    return gifDefaultFrameDuration
                }
                return frameDuration.doubleValue > 0.011 ? frameDuration.doubleValue : gifDefaultFrameDuration
            }

            let frameCount = CGImageSourceGetCount(imageSource)
            var images = [Image]()
            var gifDuration = 0.0
            for i in 0 ..< frameCount {
                guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, options) else {
                    return nil
                }
                
                if frameCount == 1 {
                    // Single frame
                    gifDuration = Double.infinity
                } else {
                    // Animated GIF
                    guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil),let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary else {
                        return nil
                    }
                    gifDuration += frameDuration(from: gifInfo)
                }
                images.append(KingFisher<Image>.image(cgImage: imageRef, scale: scale, refImage: nil))
            }
            return (images, gifDuration)
        }
        
        // Start of kf.animatedImageWithGIFData
        let options: NSDictionary = [kCGImageSourceShouldCache as String: true, kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF]
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, options) else {
            return nil
        }
        
        #if os(macOS)
            guard let (images, gifDuration) = decode(from: imageSource, for: options) else {
                return nil
            }
            let image = Image(data: data)
            image?.kf.images = images
            image?.kf.duration = gifDuration
            
            return image
        #else
            if preloadAll {
                guard let (images, gifDuration) = decode(from: imageSource, for: options) else {
                    return nil
                }
                let image = KingFisher<Image>.animated(with: images, forDuration: duration <= 0.0 ? gifDuration : duration)
                image?.kf.animatedImageData = data
                return image
            } else {
                let image = Image(data: data)
                image?.kf.animatedImageData = data
                image?.kf.imageSource = ImageSource(ref: imageSource)
                return image
            }
        #endif
    }
    
    static func image(data: Data, scale: CGFloat, preloadAllGIFData: Bool) -> Image? {
        var image: Image?
        
        #if os(macOS)
            switch data.kf.imageFormat {
            case .JPEG: image = Image(data: data)
            case .PNG: image = Image(data: data)
            case .GIF: image = KingFisher<Image>.animated(with: data, scale: scale, duration: 0.0, preloadAll: preloadAllGIFData)
            case .unknown: image = Image(data: data)
            }
        #else
            switch data.kf.imageFormat {
            case .JPEG: image = Image(data: data, scale: scale)
            case .PNG: image = Image(data: data, scale: scale)
            case .GIF: image = KingFisher<Image>.animated(with: data, scale: scale, duration: 0.0, preloadAll: preloadAllGIFData)
            case .unknown: image = Image(data: data, scale: scale)
            }
        #endif
        
        return image
    }
}

/// Reference the source image reference
class ImageSource {
    var imageRef: CGImageSource?
    init(ref: CGImageSource) {
        self.imageRef = ref
    }
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

// MARK: - Image format
private struct ImageHeaderData {
    static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
    static var JPEG_IF: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47, 0x49, 0x46]
}

enum ImageFormat {
    case unknown, PNG, JPEG, GIF
}


// MARK: - Misc Helpers
public struct DataProxy {
    fileprivate let base: Data
    init(proxy: Data) {
        base = proxy
    }
}

extension Data: KingFisherCompatible {
    public typealias CompatibleType = DataProxy
    public var kf: DataProxy {
        return DataProxy(proxy: self)
    }
}

extension DataProxy {
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 8)
        (base as NSData).getBytes(&buffer, length: 8)
        if buffer == ImageHeaderData.PNG {
            return .PNG
        } else if buffer[0] == ImageHeaderData.JPEG_SOI[0] &&
            buffer[1] == ImageHeaderData.JPEG_SOI[1] &&
            buffer[2] == ImageHeaderData.JPEG_IF[0]
        {
            return .JPEG
        } else if buffer[0] == ImageHeaderData.GIF[0] &&
            buffer[1] == ImageHeaderData.GIF[1] &&
            buffer[2] == ImageHeaderData.GIF[2]
        {
            return .GIF
        }
        
        return .unknown
    }
}
