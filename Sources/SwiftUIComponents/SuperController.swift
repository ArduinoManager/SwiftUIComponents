//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import Foundation

public enum ControllerType: String, Codable {
    case menu
    case list
    case view
    case tabBar
}

public class SuperController: Identifiable, Codable {
    public let id: UUID
    public var type: ControllerType
    
    public init(type: ControllerType) {
        self.id = UUID()
        self.type = type
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case id
        case type
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ControllerType.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
    }
}
