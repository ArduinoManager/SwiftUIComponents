//
//  File.swift
//
//
//  Created by Fabrizio Boco on 4/5/22.
//

import SwiftUI

public class TabItem: Hashable {
    public var key: Key
    public var title: String
    public var systemIcon: String?
    public var icon: String?
    public var iconColor: Color?

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
}
