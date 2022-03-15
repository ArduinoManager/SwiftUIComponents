//
//  MenuController.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import Foundation
import SwiftUI

public typealias Key = Int

public class MenuItem: Hashable {
    var key: Key
    var title: String
    var systemIcon: String?
    var icon: Image?
    var view: AnyView?
    var height: CGFloat?
    var handler: (() -> Void)?

    public init() {
        key = -1
        title = ""
        systemIcon = ""
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
}

public class TabMenuItem: MenuItem {
    
    public init(key: Key, title: String, systemIcon: String, view: AnyView) {
        super.init()
        self.key = key
        self.title = title
        self.systemIcon = systemIcon
        self.icon = nil
        self.view = view
    }
    
    public init(key: Key, title: String, icon: Image, view: AnyView) {
        super.init()
        self.key = key
        self.title = title
        self.systemIcon = nil
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
    var color: Color?
    public init(color: Color? = nil) {
        super.init()
        title = "\(UUID())"
        self.color = color
    }
}

public class HandlerMenuItem: MenuItem {
    
    public init(title: String, systemIcon: String, handler: @escaping (() -> Void)) {
        super.init()
        self.title = title
        self.systemIcon = systemIcon
        self.handler = handler
    }
    
    public init(title: String, icon: Image, handler: @escaping (() -> Void)) {
        super.init()
        self.title = title
        self.systemIcon = nil
        self.icon = icon
        self.handler = handler
    }
}

public class MenuController: ObservableObject {
    @Published public var currentTab: Key
    @Published var showMenu: Bool
    var sideTitleView: AnyView?
    @Published public var itemsColor: Color
    var selectedItemBackgroundColor: Color
    @Published public var backgroundColor: Color
    var autoClose: Bool
    var openButtonAtTop: Bool
    var openButtonColor: Color
    var openButtonIcon: String
    var openButtonSize: CGFloat
    var titleView: AnyView?
    var titleViewBackgroundColor: Color
    var menuItems: [MenuItem]
    var inspector: AnyView?

#if os(iOS)

    public init(menuItems: [MenuItem],
                autoClose: Bool = true,
                openButtonAtTop: Bool = true,
                openButtonColor: Color = Color(uiColor: .label),
                openButtonIcon: String = "line.3.horizontal",
                openButtonSize: CGFloat = 20.0,
                sideTitleView: AnyView? = nil,
                backgroundColor: Color = Color(uiColor: .systemBackground),
                itemsColor: Color = Color(uiColor: .label),
                selectedItemBackgroundColor: Color = Color(uiColor: .systemGray4),
                titleView: AnyView? = nil,
                titleViewBackgroundColor: Color = Color(uiColor: .systemBackground)) {
        showMenu = false
        self.menuItems = menuItems
        self.autoClose = autoClose
        self.openButtonAtTop = openButtonAtTop
        self.openButtonColor = openButtonColor
        self.openButtonIcon = openButtonIcon
        self.openButtonSize = openButtonSize
        self.sideTitleView = sideTitleView
        self.backgroundColor = backgroundColor
        self.itemsColor = itemsColor
        self.selectedItemBackgroundColor = selectedItemBackgroundColor
        self.titleView = titleView
        self.titleViewBackgroundColor = titleViewBackgroundColor
        currentTab = menuItems[0].key
    }
    
    #endif
    
    #if os(macOS)
    
    /// Creates a new Menu Controller
    ///
    /// - Parameters:
    ///   - menuItems: menu items
    ///   - sideTitleView: menu panel title view
    ///   - backgroundColor: left side background color
    ///   - itemsColor: items color
    ///   - titleView: content panel title view
    ///   - titleViewBackgroundColor: content panel title view color
    ///   - inspector: right side inspector
    ///   
    public init(menuItems: [MenuItem],
                sideTitleView: AnyView? = nil,
                backgroundColor: Color = Color(NSColor.windowBackgroundColor),
                itemsColor: Color = Color(NSColor.labelColor),
                titleView: AnyView? = nil,
                titleViewBackgroundColor: Color = Color(NSColor.windowBackgroundColor),
                inspector: AnyView? = nil
    ) {
        showMenu = false
        self.menuItems = menuItems
        self.autoClose = false
        self.openButtonAtTop = false
        self.openButtonColor = Color(NSColor.labelColor)
        self.openButtonIcon = ""
        self.openButtonSize = 0.0
        self.sideTitleView = sideTitleView
        self.backgroundColor = backgroundColor
        self.itemsColor = itemsColor
        self.selectedItemBackgroundColor = Color(NSColor.labelColor)
        self.titleView = titleView
        self.titleViewBackgroundColor = titleViewBackgroundColor        
        self.inspector = inspector
        currentTab = menuItems[0].key
    }
    
    #endif
    
    
}
