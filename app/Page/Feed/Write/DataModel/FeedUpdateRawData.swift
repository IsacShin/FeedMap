//
//  FeedUpdateRawData.swift
//  app
//
//  Created by 신이삭 on 2023/06/23.
//

import Foundation

struct FeedUpdateRawData: Codable {
    var resultCode: Int?
}

extension FeedUpdateRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FeedUpdateRawData.self, from: data)
    }
}
