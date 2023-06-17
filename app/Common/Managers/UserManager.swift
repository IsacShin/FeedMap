//
//  UserManager.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import AuthenticationServices
import GoogleSignIn

enum LoginType {
    case GOOGLE
    case APPLE
}

protocol FeedAppLogin {
    func google()
    func apple()
    func logout()
}

final class UserManager: NSObject, FeedAppLogin {
    
    public static let shared = UserManager()
    
    private let disposeBag = DisposeBag()

    public var currentLocation = CLLocation(latitude: 37.476284, longitude: 127.03532)
    
    public var loginSuccessHandler: (() -> Void)?
    
    private var clManager: CLLocationManager?
    
    public var token: String?
    
    public var name: String?
    
    public var loginType: LoginType = .APPLE
    
    func google() {
        guard let topVC = UIApplication.topViewController() else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { result, error in
            guard error == nil else { return }
            guard let result else { return }
            
            let email = result.user.profile?.email
            let name = result.user.profile?.name

            let idToken       = result.user.idToken?.tokenString
            let accessToken   = result.user.accessToken
            let refreshToken  = result.user.refreshToken
            let clientID      = result.user.userID
            self.loginType = .GOOGLE
            self.loginSuccess(token: idToken, name: name)
        }
        
    }
    
    func apple() {
        // Sign in with Apple 은 iOS 13.0 부터 사용이 가능
        guard #available(iOS 13.0, *) else {
            return
        }
        
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func logout() {
        
        if self.loginType == .GOOGLE {
        
        }
        
        self.token = nil
        self.name = nil
        UDF.removeObject(forKey: "idToken")
        UDF.removeObject(forKey: "userName")
        NaviManager.shared.resetNavi()
    }
    
    public func loginSuccess(token: String?, name: String?) {
        guard let token = token,
              let name = name else { return }
        NaviManager.shared.resetNavi {
            self.token = token
            self.name = name
            UDF.setValue(self.token, forKey: "idToken")
            UDF.setValue(self.name, forKey: "userName")
        }
    }
    
}

extension UserManager: ASAuthorizationControllerDelegate {
    // 인증이 성공시
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let uCredencial = authorization.credential as? ASAuthorizationAppleIDCredential else{
            return
        }
        
        let snsId = uCredencial.user
        
        guard let identityToken = uCredencial.identityToken,
              let tokenStr = String(data: identityToken, encoding: .utf8) else{
            return
        }
        
        guard let uAuthToken = uCredencial.authorizationCode,
              let uAuthText = String(data: uAuthToken, encoding: .utf8) else{
            return
        }
        
        guard let name = uCredencial.fullName else { return }
        
        let fName = "\(name.familyName)\(name.givenName)"
        print("userId = \(snsId)\n")
        print("authCode = \(uAuthText)\n")
        print("idToken = \(tokenStr)\n")
        self.loginType = .APPLE
        self.loginSuccess(token: tokenStr, name: fName)
        
    }
    
    // 인증 실패
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        CommonLoading.shared.hide()
        let uCode = (error as NSError).code
        if uCode == 1001 {
            // 사용자 취소 케이스
            return
        }
        CommonAlert.showAlertType(vc: UIApplication.topViewController()!, message: "문제가 발생했습니다.\n잠시 후 다시 시도해주세요.", nil)
    }
}
