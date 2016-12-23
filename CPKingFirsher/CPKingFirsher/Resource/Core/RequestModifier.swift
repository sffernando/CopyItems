//
//  RequestModifier.swift
//  CPKingFirsher
//
//  Created by fernando on 2016/12/23.
//  Copyright © 2016年 fernando. All rights reserved.
//

import Foundation

///// Request modifier of image downloader.
//public protocol ImageDownloadRequestModifier {
//    func modified(for request: URLRequest) -> URLRequest?
//}
//

/// Request modifier of image downloader.
public protocol ImageDownloadRequestModifier {
    func modified(for request: URLRequest) -> URLRequest?
}

//struct NoModifier: ImageDownloadRequestModifier {
//    static let `default` = NoModifier()
//    private init() {}
//    func modified(for request: URLRequest) -> URLRequest? {
//        return request
//    }
//}
//

struct NoModifier: ImageDownloadRequestModifier {
    static let `default` = NoModifier()
    private init() {}
    func modified(for request: URLRequest) -> URLRequest? {
        return request;
    }
}

//public struct AnyModifier: ImageDownloadRequestModifier {
//    
//    let block: (URLRequest) -> URLRequest?
//    
//    public func modified(for request: URLRequest) -> URLRequest? {
//        return block(request)
//    }
//    
//    public init(modify: @escaping (URLRequest) -> URLRequest? ) {
//        block = modify
//    }
//}

public struct AnyModifier: ImageDownloadRequestModifier {
    
    let block: (URLRequest) -> URLRequest?
    
    public func modified(for request: URLRequest) -> URLRequest? {
        return block(request)
    }
    
    public init(modify: @escaping (URLRequest) -> URLRequest? ) {
        block = modify
    }
}
