//
//  File.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

public class TabBarController: ObservableObject, Codable {
    @Published public var tabs: [TabItem]
    @Published public var viewProvider: (_ controller: TabBarController, _ tab: TabItem) -> AnyView
    public var backgroundColor: Color
    public var itemsColor: Color

    #if os(iOS)
        public init(views: [TabItem],
                    viewProvider: @escaping (_ controller: TabBarController, _ tab: TabItem) -> AnyView,
                    backgroundColor: Color = Color(uiColor: .systemBackground),
                    itemsColor: Color = Color(uiColor: .label))
        {
            tabs = views
            self.backgroundColor = backgroundColor
            self.itemsColor = itemsColor
            self.viewProvider = viewProvider
        }
    #endif
    #if os(macOS)
        public init(views: [TabItem],
                    viewProvider: @escaping (_ controller: TabBarController, _ tab: TabItem) -> AnyView)
        {
            tabs = views
            backgroundColor = .red
            itemsColor = .red
            self.viewProvider = viewProvider
        }
    #endif
    
    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case tabs
        case backgroundColor
        case itemsColor
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tabs = try values.decode([TabItem].self, forKey: .tabs)
        backgroundColor = try values.decode(Color.self, forKey: .backgroundColor)
        itemsColor = try values.decode(Color.self, forKey: .itemsColor)
        viewProvider = { _,_ in
            AnyView(EmptyView())
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabs, forKey: .tabs)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(itemsColor, forKey: .itemsColor)
    }
}
