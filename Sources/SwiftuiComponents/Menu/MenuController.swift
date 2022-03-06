//
//  MenuController.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import Foundation
import SwiftUI

public class MenuItem: Hashable {
    var title: String
    var icon: String
    var view: AnyView?
    var height: CGFloat?
    var handler: (() -> Void)?

    public init() {
        title = ""
        icon = ""
    }
    
    public static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.title == rhs.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    @ViewBuilder
    func makeView() -> some View {
        view
    }
}

public class TabMenuItem: MenuItem {
    
    public init(title: String, icon: String, view: AnyView) {
        super.init()
        self.title = title
        self.icon = icon
        self.view = view
    }
}

public class TabMenuSpacer: MenuItem {
    
    public init(height: CGFloat) {
        super.init()
        self.height = height
    }
}

public class TabMenuDivider: MenuItem {
    
    public override init() {
        super.init()
        title = "\(UUID())"
    }
}

public class HandlerMenuItem: MenuItem {
    
    public init(title: String, icon: String, handler: @escaping (() -> Void)) {
        super.init()
        self.title = title
        self.icon = icon
        self.handler = handler
    }
}

public class MenuController: ObservableObject {
    @Published var currentTab: String
    @Published var showMenu: Bool
    var sideViewImage: String?
    var sideViewTitle: String?
    var itemsColor: Color
    var selectedItemBackgroundColor: Color
    public var menuBackgroundColor: Color = Color(uiColor: .systemBackground)
    public var autoClose = true
    public var openMenuOnTop = true
    public var openMenuIcon = "line.3.horizontal"
    public var openMenuSize: CGFloat = 20.0
    public var titleView: AnyView?
    public var titleViewBackground: Color = Color(uiColor: .systemBackground)
    public var menuItems = [MenuItem]()
    
    public init(menuItems: [MenuItem], sideViewImage: String? = nil, sideViewTitle: String? = nil, itemsColor: Color = Color(uiColor: .label), selectedItemBackgroundColor: Color = Color(uiColor: .systemGray4)) {
        showMenu = false
        self.sideViewImage = sideViewImage
        self.sideViewTitle = sideViewTitle
        self.itemsColor = itemsColor
        self.selectedItemBackgroundColor = selectedItemBackgroundColor
        self.menuItems = menuItems                
        currentTab = menuItems[0].title
    }
}
