//
//  MyPageVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/24.
//

import Foundation
import RxCocoa
import RxSwift

protocol MyPageVM {
    var input: MyPageVMInput { get }
    var output: MyPageVMOutput { get }
}

protocol MyPageVMInput {
    
}

protocol MyPageVMOutput {
    
}

final class MyPageVMImpl: MyPageVM, MyPageVMInput, MyPageVMOutput {
    var input: MyPageVMInput {
        return self
    }
    
    var output: MyPageVMOutput {
        return self
    }
    
    private let diposeBag = DisposeBag()
}
