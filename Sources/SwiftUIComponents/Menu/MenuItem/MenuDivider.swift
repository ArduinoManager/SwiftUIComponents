//
//  TabMenuDivider.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

/// Line Separator between items
///
public class MenuDivider: MenuItem {
    public var color: Color

    #if os(iOS)
        public init(color: Color = Color(uiColor: .label)) {
            self.color = color
            super.init(type: .divider)
            title = "\(UUID())"
        }
    #endif

    #if os(macOS)
        public init(color: Color = Color(nsColor: .labelColor)) {
            self.color = color
            super.init(type: .divider)
            title = "\(UUID())"
        }
    #endif
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case color
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        color = try values.decode(Color.self, forKey: .color)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try super.encode(to: encoder)
    }
}
