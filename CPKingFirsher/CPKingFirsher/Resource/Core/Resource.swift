//
//  Resource.swift
//  CPKingFirsher
//
//  Created by koudai on 2016/12/8.
//  Copyright © 2016年 fernando. All rights reserved.
//

import Foundation

/// `Resource` protocol defines how to download and cache a resource from netwrk
public protocol Resource {
    /// The key used in cache
    var cacheKey: String { get }
    /// The target image URL
    var downloadURL: URL { get }
}

/**
 ImageResource is a simple combination of `downloadURL` and `cacheKey`.
 
 When passed to image view set methods, Kinfisher will try to dowload the target image from the `downloadURL`, and then store it with the `cacheKey` as the key in cache
 */
public struct ImageSource: Resource {
    /// The key used in cache
    public let cacheKey: String
    /// The target image URL
    public let downloadURL: URL
    
    
    /// Create a resource
    ///
    /// - Parameters:
    ///   - downloadURL: The target image URL
    ///   - cacheKey: The cache key. if `nil` KingFisher will use the `absoluteString` of `downloadURL` as the key
    public init(downloadURL: URL, cacheKey: String) {
        self.cacheKey = cacheKey
        self.downloadURL = downloadURL
    }
}

/**
 URL confirms to `Resource` in KingFisher.
 The `absoluteString` of this URL is used as `cacheKey`. And the URL itself will be used as `downloadURL`
 If you need customsize the url and/or cache key, use `ImageResource` instead.
 */
extension URL: Resource {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self }
}
