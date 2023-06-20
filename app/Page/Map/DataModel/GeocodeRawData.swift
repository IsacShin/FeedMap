//
//  geocodeRawData.swift
//  app
//
//  Created by 신이삭 on 2023/06/20.
//

import Foundation

struct GeocodeRawData: Codable {
    var results: [AddrRawData]?
}
extension GeocodeRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GeocodeRawData.self, from: data)
    }
}

struct AddrRawData: Codable {
    var geometry: GeometryRawData?
}

extension AddrRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AddrRawData.self, from: data)
    }
}

struct GeometryRawData: Codable {
    var location: LocationRawData?
}

extension GeometryRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GeometryRawData.self, from: data)
    }
}

struct LocationRawData: Codable {
    let lat: Double?
    let lng: Double?
}

extension LocationRawData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LocationRawData.self, from: data)
    }
}
