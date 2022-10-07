//
//  TabMenuDivider.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

/// Line Separator between items
///
public class MenuDivider: SUCMenuItem {
    public var color: GenericColor

    public init(color: GenericColor = .systemLabel) {
            self.color = color
            super.init(type: .divider)
            title = "\(UUID())"
        }
   
    
    override public var debugDescription: String {
        return "[\(key) Divider]"
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case color
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        color = try values.decode(GenericColor.self, forKey: .color)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try super.encode(to: encoder)
    }
}
