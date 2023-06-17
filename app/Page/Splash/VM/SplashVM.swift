//
//  SplashVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import Foundation
import RxSwift
import RxCocoa

enum LaunchState {
    case firstLaunch
    case yetLaunch
}

protocol SplashVM {
    var input: SplashVMInput { get }
    var output: SplashVMOutput { get }
}

protocol SplashVMInput {
    func startLaunch()
}

protocol SplashVMOutput {
    var nextAction: PublishRelay<LaunchState> { get }

}

final class SplashVMImpl: SplashVM, SplashVMInput, SplashVMOutput {
    var input: SplashVMInput {
        return self
    }
    
    var output: SplashVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    
    //MARK: - output
    var nextAction = PublishRelay<LaunchState>()
    
    func startLaunch() {
        if UDF.bool(forKey: "firstLaunch") == false {
            self.nextAction.accept(.firstLaunch)
        } else {
            self.nextAction.accept(.yetLaunch)
        }
    }
}
