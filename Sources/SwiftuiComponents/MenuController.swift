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
    @Published var showMenu = false
    var image = ""
    var title = ""
    var itemsColor: Color = Color(uiColor: .label)
    var selectedItemBackgroundColor: Color = Color(uiColor: .systemGray4)
    var menuBackgroundColor: Color = Color(uiColor: .systemBackground)
    var autoClose = true
    var openMenuOnTop = true
    var openMenuIcon = "line.3.horizontal"
    var openMenuSize: CGFloat = 20.0
    var titleView: AnyView?
    var titleViewBackground: Color = Color(uiColor: .systemBackground)
    var menuItems = [MenuItem]()

    init(menuItems: [MenuItem]) {
        self.menuItems = menuItems                
        currentTab = menuItems[0].title
    }
}
