//
//  File.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

public class TabBarController: SuperController, ObservableObject {
    @Published public var tabs: [TabItem]
    @Published public var viewProvider: ((_ controller: TabBarController, _ tab: TabItem) -> AnyView)?
    @Published public var tabBarPosition: TabBar.TabBarPosition
    @Published public var backgroundColor: Color

    #if os(iOS)
        public init(tabs: [TabItem],
                    tabBarPosition: TabBar.TabBarPosition,
                    viewProvider: ((_ controller: TabBarController, _ tab: TabItem) -> AnyView)?,
                    backgroundColor: Color = Color(uiColor: .systemBackground),
                    itemsColor: Color = Color(uiColor: .label))
        {
            self.tabs = tabs
            self.tabBarPosition = tabBarPosition
            self.backgroundColor = backgroundColor
            self.viewProvider = viewProvider
            super.init(type: .tabBar)

            let dups = Dictionary(grouping: tabs, by: { $0.key }).filter { $1.count > 1 }.keys
            if !dups.isEmpty {
                fatalError("Duplicated keys: \(dups)")
            }
        }
    #endif
    
    #if os(macOS)
        public init(tabs: [TabItem],
                    tabBarPosition: TabBar.TabBarPosition,
                    viewProvider: ((_ controller: TabBarController, _ tab: TabItem) -> AnyView)?,
                    backgroundColor: Color = Color(nsColor: .windowBackgroundColor),
                    itemsColor: Color = Color(nsColor: .labelColor)
        )
        {
            self.tabs = tabs
            self.tabBarPosition = tabBarPosition
            self.backgroundColor = backgroundColor
            self.viewProvider = viewProvider
            super.init(type: .tabBar)

            let dups = Dictionary(grouping: tabs, by: { $0.key }).filter { $1.count > 1 }.keys
            if !dups.isEmpty {
                fatalError("Duplicated keys: \(dups)")
            }
        }
    #endif

    public func addTab(tab: TabItem) {
        tabs.append(tab)
        let dups = Dictionary(grouping: tabs, by: { $0.key }).filter { $1.count > 1 }.keys
        if !dups.isEmpty {
            fatalError("Duplicated keys: \(dups)")
        }
    }

    public func deleteTabAt(index: Int) {
        tabs.remove(at: index)
    }

    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case tabs
        case backgroundColor
        case position
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tabs = try values.decode([TabItem].self, forKey: .tabs)
        backgroundColor = try values.decode(Color.self, forKey: .backgroundColor)
        tabBarPosition = try values.decode(TabBar.TabBarPosition.self, forKey: .position)
        viewProvider = { _, _ in
            AnyView(EmptyView())
        }
        super.init(type: .tabBar)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabs, forKey: .tabs)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(tabBarPosition, forKey: .position)
        try super.encode(to: encoder)
    }
}
