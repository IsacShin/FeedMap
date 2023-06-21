//
//  Double+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import Foundation

extension Double {
  static func equal(_ lhs: Double, _ rhs: Double, precise value: Int? = nil) -> Bool {
    guard let value = value else {
      return lhs == rhs
    }
        
    return lhs.precised(value) == rhs.precised(value)
  }

  func precised(_ value: Int = 1) -> Double {
    let offset = pow(10, Double(value))
    return (self * offset).rounded() / offset
  }
}

extension Double {
  var prettyDistance: String {
    guard self > -.infinity else { return "?" }

    let formatter = LengthFormatter()
    formatter.numberFormatter.maximumFractionDigits = 2

    if self >= 1000 {
      return formatter.string(fromValue: self / 1000, unit: LengthFormatter.Unit.kilometer)
    } else {
      let value = Double(Int(self)) // 미터로 표시할 땐 소수점 제거
      return formatter.string(fromValue: value, unit: LengthFormatter.Unit.meter)
    }
  }
}

