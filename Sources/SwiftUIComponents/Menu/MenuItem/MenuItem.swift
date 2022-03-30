//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

public typealias Key = Int

public enum MenuItemType: String, Codable {
    case item
    case action
    case divider
    case spacer
}

/// Generic Menu Item - Do not instantiate this but the subclasses
///
public class MenuItem: Hashable, CustomDebugStringConvertible, Encodable, Decodable {
    public var key: Key
    public var title: String
    public var systemIcon: String?
    public var icon: String?
    public var useSystemIcon: Bool
    public var type: MenuItemType

    public init(type: MenuItemType) {
        self.type = type
        key = UUID().hashValue
        title = ""
        systemIcon = ""
        useSystemIcon = true
    }

    public static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.title == rhs.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public var debugDescription: String {
        return "[\(key)]"
    }
    
    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case type
        case key
        case title
        case icon
        case systemIcon
        case useSystemIcon
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(MenuItemType.self, forKey: .type)
        key = try values.decode(Int.self, forKey: .key)
        title = try values.decode(String.self, forKey: .title)
        icon = try? values.decode(String.self, forKey: .icon)
        systemIcon = try? values.decode(String.self, forKey: .systemIcon)
        useSystemIcon = try values.decode(Bool.self, forKey: .useSystemIcon)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(key, forKey: .key)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(useSystemIcon, forKey: .useSystemIcon)
    }
}
