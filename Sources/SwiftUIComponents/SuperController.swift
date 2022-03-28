//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import Foundation

enum ControllerType: Codable {
    case menu
    case list
}

public class SuperController: Codable {
    var type: ControllerType
    
    init(type: ControllerType) {
        self.type = type
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ControllerType.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
}
