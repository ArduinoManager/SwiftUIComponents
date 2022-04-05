//
//  File.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

public class TabBarController: ObservableObject {
    @Published public var tabs: [TabItem]
    @Published public var viewProvider: (_ controller: TabBarController, _ tab: TabItem) -> AnyView
    var backgroundColor: Color
    var itemsColor: Color

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
}
