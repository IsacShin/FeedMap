//
//  IdLoginVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/30.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

protocol IdLoginVM {
    var input: IdLoginVMInput { get }
    var output: IdLoginVMOutput { get }
}

protocol IdLoginVMInput {
    func regist(info: [String: Any], completion: @escaping () -> Void)

}

protocol IdLoginVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var success: BehaviorRelay<Bool?> { get }
}

final class IdLoginVMImpl: IdLoginVM, IdLoginVMInput, IdLoginVMOutput {
    var input: IdLoginVMInput {
        return self
    }
    
    var output: IdLoginVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    var error = BehaviorRelay<Error?>(value: nil)
    var success = BehaviorRelay<Bool?>(value: nil)
    
    func regist(info: [String: Any], completion: @escaping () -> Void) {
        
    }
}

