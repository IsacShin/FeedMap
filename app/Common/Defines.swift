//
//  Defines.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

// MARK: - SCREEN 관련
let WINDOW                  = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let SCREEN_WIDTH            = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT           = UIScreen.main.bounds.size.height
let STATUS_HEIGHT           = WINDOW?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

var SAFEAREA_TOP: CGFloat {
    return WINDOW?.safeAreaInsets.top ?? 0
}

var SAFEAREA_BOTTOM: CGFloat {
    return WINDOW?.safeAreaInsets.bottom ?? 0
}

var SAFEAREA_INSET: UIEdgeInsets {
    return WINDOW?.safeAreaInsets ?? .zero
}

// MARK: - UI 관련
let LIGHT_COLOR = UIColor.white
let DARK_COLOR = UIColor.darkGray

// MARK: - Shortcut
/// AppDelegate
let AppD: AppDelegate = UIApplication.shared.delegate as! AppDelegate
/// UserDefaults.standard
let UDF = UserDefaults.standard
/// DIManager
let DIM = DIManager.shared
/// ProgressBar
let LOADING = CommonLoading.shared

// MARK: - HTTP통신
let DOMAIN                  = "http://52.78.250.89:8080"
let SEARCH_KEYWORD          = "https://dapi.kakao.com/v2/local/search/keyword.json"
let KAKAO_SEARCH_KEY        = "c100792705b3b3d5dd8da673a9da10e5"

// MARK: - Device 관련
let DEVICE                  = UIDevice.current
let APP_VER                 = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
let DEVICE_TYPE             = "IOS"
let DEVICE_MODEL            = "\(DEVICE.model)\(DEVICE.name)"
let DEVICE_ID               = UIDevice.current.identifierForVendor?.uuidString
let APP_ID                  = Bundle.main.bundleIdentifier ?? "com.isac.myreview"
let DEVICE_VERSION          = "\(DEVICE.systemVersion)"
let APP_NAME                = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""

let GMAP_KEY                  = "AIzaSyAFYYYgXJeT6SCOji_uSpTSP2ckkxOLLns"
