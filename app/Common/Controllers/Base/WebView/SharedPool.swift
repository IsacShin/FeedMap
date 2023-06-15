//
//  SharedPool.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import WebKit

class SharedPool:NSObject {
    static let shared = SharedPool()
    private override init() {}
    
    /// WKWebView Cookie 공유용 Process Pool
    let commonProcessPool = WKProcessPool()
}
