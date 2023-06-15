//
//  CompletionHandlerWrapper.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//
import Foundation

class CompletionHandlerWrapper<Element> {
    private var completionHandler: ((Element) -> Void)?
    private let defaultValue: Element
    
    init(completionHandler: @escaping ((Element) -> Void), defaultValue: Element) {
        self.completionHandler = completionHandler
        self.defaultValue = defaultValue
    }
    
    func respondHandler(_ value: Element) {
        completionHandler?(value)
        completionHandler = nil
    }
    
    deinit {
        respondHandler(defaultValue)
    }
}
