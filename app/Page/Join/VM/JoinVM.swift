//
//  JoinVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/29.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

protocol JoinVM {
    var input: JoinVMInput { get }
    var output: JoinVMOutput { get }
}

protocol JoinVMInput {
    
}

protocol JoinVMOutput {
    
}

final class JoinVMImpl: JoinVM, JoinVMInput, JoinVMOutput {
    var input: JoinVMInput {
        return self
    }
    
    var output: JoinVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
}
