//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

/// Item associated to a View shown when the item is clicked
///
public class TabMenuItem: MenuItem {
    
    public init(key: Key, title: String, systemIcon: String, view: AnyView) {
        super.init(type: .item)
        self.key = key
        self.title = title
        self.systemIcon = systemIcon
        self.icon = nil
        self.view = view
        self.useSystemIcon = true
    }

    public init(key: Key, title: String, icon: String, view: AnyView) {
        super.init(type: .item)
        self.key = key
        self.title = title
        self.systemIcon = nil
        self.icon = icon
        self.view = view
        self.useSystemIcon = false
    }

    override public var debugDescription: String {
        return "[\(key) Tab \(title)]"
    }
    
    // MARK: - Encodable & Decodable

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
   
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
