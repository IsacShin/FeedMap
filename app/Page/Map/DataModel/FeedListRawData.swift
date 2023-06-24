//
//  FeedListRawData.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import Foundation

struct FeedListRawData: Codable {
    var list: [FeedRawData]?
}

extension FeedListRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FeedListRawData.self, from: data)
    }
}

struct FeedRawData: Codable {
    var id : Int?
    var title: String?
    var addr: String?
    var date: String?
    var comment: String?
    var latitude: String?
    var longitude: String?
    var memid: String?
    var img1: String?
    var img2: String?
    var img3: String?
}

extension FeedRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FeedRawData.self, from: data)
    }
}
