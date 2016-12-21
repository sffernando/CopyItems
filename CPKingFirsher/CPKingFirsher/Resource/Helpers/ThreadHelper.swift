//
//  ThreadHelper.swift
//  CPKingFirsher
//
//  Created by fernando on 2016/12/20.
//  Copyright © 2016年 fernando. All rights reserved.
//

import Foundation

extension DispatchQueue {
    // This method will disoatch the `block` to self.
    // If `self` is the main queue, and current thread is main threa, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
