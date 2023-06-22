//
//  FileUploadRawData.swift
//  app
//
//  Created by 신이삭 on 2023/06/22.
//

import Foundation

struct FileUploadRawData: Codable {
    var fileUrls: [String]?
}

extension FileUploadRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FileUploadRawData.self, from: data)
    }
}
