//
//  LoginVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import Foundation
import RxCocoa
import RxSwift

protocol LoginVM {
    var input: LoginVMInput { get }
    var output: LoginVMOutput { get }
}

protocol LoginVMInput {
    
}

protocol LoginVMOutput {
    
}

final class LoginVMImpl: LoginVM, LoginVMInput, LoginVMOutput {
    var input: LoginVMInput {
        return self
    }
    
    var output: LoginVMOutput {
        return self
    }
    
    private let diposeBag = DisposeBag()
}
