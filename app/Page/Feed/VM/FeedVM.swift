//
//  FeedVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/24.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay

protocol FeedVM {
    var input: FeedVMInput { get }
    var output: FeedVMOutput { get }
}

protocol FeedVMInput {
    
}

protocol FeedVMOutput {
    
}

final class FeedVMImpl: FeedVM, FeedVMInput, FeedVMOutput {
    var input: FeedVMInput {
        return self
    }
    
    var output: FeedVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()

}
