//
//  CommonUtils.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

class CommonUtils:NSObject {
    /// App UUID 값 반환 함수
    static func getAppUUID() -> String {
        if let idv = UIDevice.current.identifierForVendor {
            return idv.uuidString
        }else {
            return UUID().uuidString
        }
    }
    
    /// Storyboard에서 특정 ViewController를 반환
    /// - Parameter strSBName: Storyboard 이름
    /// - Parameter strControllerName: ViewController 이름
    /// - Returns: 해당 ViewController. 없으면 nil
    static func getVC(storyBoard strSBName: String, controller strControllerName: String) -> UIViewController? {
        let str: String? = strSBName
        if (strSBName == "" || str == nil) {
            return nil
        }
        
        let str2: String? = strControllerName
        if (strControllerName == "" || str2 == nil) {
            return nil
        }

        let storyboard = UIStoryboard(name: strSBName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: strControllerName)
        return vc
    }
}
