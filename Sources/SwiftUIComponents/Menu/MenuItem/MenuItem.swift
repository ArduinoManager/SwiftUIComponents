//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import SwiftUI

public typealias Key = Int

/// Generic Menu Item - Do not instantiate this but the subclasses
///
public class MenuItem: Hashable, CustomDebugStringConvertible, Encodable, Decodable {
    public var key: Key
    public var title: String
    public var systemIcon: String?
    public var icon: String?
    public var view: AnyView?
    public var useSystemIcon: Bool

    public init() {
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

    @ViewBuilder
    func makeView() -> some View {
        view
    }

    public var debugDescription: String {
        return "[\(key)]"
    }
    
    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case key
        case title
        case icon
        case systemIcon
        case useSystemIcon
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(Int.self, forKey: .key)
        title = try values.decode(String.self, forKey: .title)
        icon = try? values.decode(String.self, forKey: .icon)
        systemIcon = try? values.decode(String.self, forKey: .systemIcon)
        useSystemIcon = try values.decode(Bool.self, forKey: .useSystemIcon)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(useSystemIcon, forKey: .useSystemIcon)
    }
}
