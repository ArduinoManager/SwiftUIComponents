//
//  File.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

open class TabBarController: SuperController, ObservableObject {
    @Published public var tabs: [TabItem]
    @Published public var tabBarPosition: TabBar.TabBarPosition
    @Published public var backgroundColor: GenericColor
    @Published public var selectionColor: GenericColor

    public init(tabs: [TabItem],
                tabBarPosition: TabBar.TabBarPosition,
                backgroundColor: GenericColor = GenericColor.systemBackground,
                selectionColor: GenericColor = GenericColor.systemRed)
    {
        self.tabs = tabs
        self.tabBarPosition = tabBarPosition
        self.backgroundColor = backgroundColor
        self.selectionColor = selectionColor
        super.init(type: .tabBar)

        let dups = Dictionary(grouping: tabs, by: { $0.key }).filter { $1.count > 1 }.keys
        if !dups.isEmpty {
            fatalError("Duplicated keys: \(dups)")
        }
    }

    public func addTab(tab: TabItem) {
        tabs.append(tab)
        let dups = Dictionary(grouping: tabs, by: { $0.key }).filter { $1.count > 1 }.keys
        if !dups.isEmpty {
            fatalError("Duplicated keys: \(dups)")
        }
    }

    public func deleteTab(tab: TabItem) {
        if let idx = tabs.firstIndex(of: tab) {
            deleteTabAt(index: idx)
        }
    }

    public func deleteTabAt(index: Int) {
        tabs.remove(at: index)
    }
    
    public func headerProvider() -> AnyView? {
        return nil
    }
    public func footerProvider() -> AnyView? {
        return nil
    }

    
    public func viewProvider(tab: TabItem) -> AnyView {
        return AnyView(EmptyView())
    }

    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case tabs
        case backgroundColor
        case selectionColor
        case position
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tabs = try values.decode([TabItem].self, forKey: .tabs)
        backgroundColor = try values.decode(GenericColor.self, forKey: .backgroundColor)
        selectionColor = try values.decode(GenericColor.self, forKey: .selectionColor)
        tabBarPosition = try values.decode(TabBar.TabBarPosition.self, forKey: .position)
        super.init(type: .tabBar)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabs, forKey: .tabs)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(selectionColor, forKey: .selectionColor)
        try container.encode(tabBarPosition, forKey: .position)
        try super.encode(to: encoder)
    }
}
