//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

/// Item which only creates a space between other items
///
public class TabMenuSpacer: MenuItem {
    public var spacerHeight: CGFloat?

    public init(height: CGFloat) {
        super.init()
        spacerHeight = height
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case spacerHeight
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        spacerHeight = try values.decode(CGFloat.self, forKey: .spacerHeight)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spacerHeight, forKey: .spacerHeight)
        try super.encode(to: encoder)
    }
}

