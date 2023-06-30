//
//  UserDataModel.swift
//  app
//
//  Created by 신이삭 on 2023/06/30.
//

import Foundation

struct UserListRawData: Codable {
    var list: [UserRawData]?
}

extension UserListRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserListRawData.self, from: data)
    }
}

struct UserRawData: Codable {
    var id : Int?
    var memid: String?
    var password: String?
    var name: String?
    var profileUrl: String?
}

extension UserRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserRawData.self, from: data)
    }
}
