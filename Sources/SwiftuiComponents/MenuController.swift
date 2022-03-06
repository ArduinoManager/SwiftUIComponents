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
    @Published public var currentTab: String
    @Published public var showMenu = false
    public var image = ""
    public var title = ""
    public var itemsColor: Color = Color(uiColor: .label)
    public var selectedItemBackgroundColor: Color = Color(uiColor: .systemGray4)
    public var menuBackgroundColor: Color = Color(uiColor: .systemBackground)
    public var autoClose = true
    public var openMenuOnTop = true
    public var openMenuIcon = "line.3.horizontal"
    public var openMenuSize: CGFloat = 20.0
    public var titleView: AnyView?
    public var titleViewBackground: Color = Color(uiColor: .systemBackground)
    public var menuItems = [MenuItem]()

//    public init() {
//        showMenu = false
//        image = ""
//        title = ""
//        itemsColor = Color(uiColor: .label)
//        selectedItemBackgroundColor = Color(uiColor: .systemGray4)
//        menuBackgroundColor = Color(uiColor: .systemBackground)
//        autoClose = true
//        openMenuOnTop = true
//        openMenuIcon = "line.3.horizontal"
//        openMenuSize = 20.0
//        titleView = nil
//        titleViewBackground = Color(uiColor: .systemBackground)
//        menuItems = [MenuItem]()
//        currentTab = ""
//    }
    
    public init(menuItems: [MenuItem]) {
        self.menuItems = menuItems                
        currentTab = menuItems[0].title
    }
}
