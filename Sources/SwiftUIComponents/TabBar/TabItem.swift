//
//  File.swift
//
//
//  Created by Fabrizio Boco on 4/5/22.
//

import SwiftUI

public class TabItem: Hashable, Codable {
    public var key: Key
    public var title: String
    public var systemIcon: String?
    public var icon: String?
    public var iconColor: Color?
    public var targetViewId: UUID? /// Reserved for the generarator
    
    public init(key: Key, title: String, systemIcon: String, iconColor: Color? = nil) {
        self.key = key
        self.title = title
        self.systemIcon = systemIcon
        self.iconColor = iconColor
    }

    public init(key: Key, title: String, icon: String, iconColor: Color? = nil) {
        self.key = key
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
    }

    public static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.title == rhs.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case key
        case title
        case icon
        case systemIcon
        case iconColor
        case targetViewId
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(Int.self, forKey: .key)
        title = try values.decode(String.self, forKey: .title)
        icon = try? values.decode(String.self, forKey: .icon)
        systemIcon = try? values.decode(String.self, forKey: .systemIcon)
        iconColor = try? values.decode(Color.self, forKey: .iconColor)
        targetViewId = try? values.decode(UUID.self, forKey: .targetViewId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(iconColor, forKey: .iconColor)
        try container.encode(targetViewId, forKey: .targetViewId)
    }
}
