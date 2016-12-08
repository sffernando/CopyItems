//
//  KingFisher.swift
//  CPKingFirsher
//
//  Created by koudai on 2016/12/8.
//  Copyright © 2016年 fernando. All rights reserved.
//

import Foundation
import ImageIO

#if os(macOS)
    import AppKit
    public typealias Image = NSImage
    public typealias Color = NSClolor
    public typealias ImageView = NSImageView
    typealias Button = NSButton
#else
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
    #if !os(watchOS)
        public typealias ImageView = UIImageView
        typealias Button = UIButton
    #endif
#endif


public final class KingFisher<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol KingFisherCompatible {
    associatedtype CompatibleType
    var kf: CompatibleType { get }
}

public extension KingFisherCompatible {
    public var kf: KingFisher<Self> {
        get {
            return KingFisher(self)
        }
    }
}

extension Image: KingFisherCompatible { }
#if !os(watchOS)
    extension ImageView: KingFisherCompatible { }
    extension Button: KingFisherCompatible { }
#endif
