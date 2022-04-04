//
//  ViewMenuItem.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

/// Item associated to a View shown when the item is clicked
///
public class MenuView: MenuItem {
    public var targetViewId: UUID? /// Reserved for the generarator
    
    public init(key: Key, title: String, systemIcon: String) {
        super.init(type: .item)
        self.key = key
        self.title = title
        self.systemIcon = systemIcon
        self.icon = nil
        self.useSystemIcon = true
    }

    public init(key: Key, title: String, icon: String) {
        super.init(type: .item)
        self.key = key
        self.title = title
        self.systemIcon = nil
        self.icon = icon
        self.useSystemIcon = false
    }

    override public var debugDescription: String {
        if let id = targetViewId {
            if useSystemIcon {
                return "[\(key) Menu: \(title) View ID: \(id) System Icon \(systemIcon!)]"
            }
            else {
                return "[\(key) Menu: \(title) View ID: \(id) Icon \(icon!)]"
            }
        }
        else {
            if useSystemIcon {
                return "[\(key) Menu: \(title) View ID: - System Icon \(systemIcon!)]"
            }
            else {
                return "[\(key) Menu: \(title) View ID: - Icon \(icon!)]"
            }
        }
    }

    enum CodingKeys: CodingKey {
        case targetViewId
    }
    // MARK: - Encodable & Decodable

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        targetViewId = try? values.decode(UUID.self, forKey: .targetViewId)
        try super.init(from: decoder)
    }
   
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(targetViewId, forKey: .targetViewId)
        try super.encode(to: encoder)
    }
}
