//
//  DIManager.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import Swinject

// MARK: 의존성 주입 관련 매니저
// 컨테이너에 VC등록 및 resolve를 통한 getVC() 역할 수행
final class DIManager {
    static let shared = DIManager()
    let container = Container()
    
    init() {
        self.registVC()
    }
    
    private func registVC() {
        self.container.register(AccessGuideVC.self) { _ in
            return .init()
        }
        
        self.container.register(MapVC.self) { _ in
            return .init()
        }
        
        self.container.register(FeedVC.self) { _ in
            return .init()
        }
        
        self.container.register(MyPageVC.self) { _ in
            return .init()
        }
        
        self.container.register(LoginVC.self) { _ in
            return .init(vm: LoginVMImpl())
        }
    
    }
}