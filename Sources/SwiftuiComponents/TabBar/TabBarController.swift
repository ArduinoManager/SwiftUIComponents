//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

public class TabItem: Hashable {
    var title: String
    var systemIcon: String?
    var icon: String?
    var tab: AnyView
    
    public init(title: String, systemIcon: String, tab: AnyView) {
        self.title = title
        self.systemIcon = systemIcon
        self.tab = tab
    }
    
    public init(title: String, icon: String, tab: AnyView) {
        self.title = title
        self.icon = icon
        self.tab = tab
    }
    
    public static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.title == rhs.title
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    @ViewBuilder
    func makeTab() -> some View {
        tab
    }
}


public class TabBarController: ObservableObject {
    @Published public var tabs: [TabItem]
    var backgroundColor: Color
    var itemsColor: Color
    
    public init(views: [TabItem], backgroundColor: Color = Color(uiColor: .systemBackground), itemsColor: Color = Color(uiColor: .label)) {
        self.tabs = views
        self.backgroundColor = backgroundColor
        self.itemsColor = itemsColor
    }
}
