//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

/// Menu Item associated to an action activated when the item is clicked
///
public class TabMenuAction: MenuItem {
    //public var handler: (_ controller: MenuController, _ item: TabMenuAction) -> Void

    public init(key: Key, title: String, systemIcon: String
                //, handler: @escaping ((_ controller: MenuController, _ item: TabMenuAction) -> Void)
    ) {
        //self.handler = handler
        super.init(type: .action)
        self.key = key
        self.title = title
        self.systemIcon = systemIcon
    }

    public init(title: String, icon: String
                //, handler: @escaping ((_ controller: MenuController, _ item: TabMenuAction) -> Void)
    ) {
        //self.handler = handler
        super.init(type: .action)
        self.title = title
        self.systemIcon = nil
        self.icon = icon
    }
    
    override public var debugDescription: String {
        return "[\(key) Handler \(title)]"
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case handler
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
