//
//  MenuController.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import Foundation
import SwiftUI

public class MenuController: SuperController, ObservableObject {
    @Published public var currentTab: Key
    @Published var showMenu: Bool
    @Published public var sideTitleView: AnyView?
    @Published public var itemsColor: Color
    @Published public var selectedItemBackgroundColor: Color
    @Published public var backgroundColor: Color
    @Published public var autoClose: Bool
    @Published public var openButtonAtTop: Bool
    @Published public var openButtonColor: Color
    @Published public var openButtonIcon: String
    @Published public var openButtonSize: CGFloat
    @Published public var titleView: AnyView?
    @Published public var titleViewBackgroundColor: Color
    @Published public var menuItems: [MenuItem]
    public var menuHandler: ((_ controller: MenuController, _ item: MenuAction) -> Void)?
    @Published public var inspector: AnyView?
    var boostrap: String? = "A"

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
                    titleViewBackgroundColor: Color = Color(uiColor: .systemBackground),
                    menuHandler: @escaping (_ controller: MenuController, _ item: MenuAction) -> Void) {
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
            self.menuHandler = menuHandler
            currentTab = menuItems[0].key

            super.init(type: .menu)

            let dups = Dictionary(grouping: self.menuItems, by: { $0.key }).filter { $1.count > 1 }.keys
            if !dups.isEmpty {
                fatalError("Duplicated keys: \(dups)")
            }
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
                    inspector: AnyView? = nil,
                    menuHandler: @escaping (_ controller: MenuController, _ item: MenuAction) -> Void) {
            //print(menuItems)

            showMenu = false
            self.menuItems = menuItems
            autoClose = false
            openButtonAtTop = false
            openButtonColor = Color(NSColor.labelColor)
            openButtonIcon = ""
            openButtonSize = 0.0
            self.sideTitleView = sideTitleView
            self.backgroundColor = backgroundColor
            self.itemsColor = itemsColor
            selectedItemBackgroundColor = Color(NSColor.labelColor)
            self.titleView = titleView
            self.titleViewBackgroundColor = titleViewBackgroundColor
            self.inspector = inspector
            self.menuHandler = menuHandler
            currentTab = menuItems[0].key

            super.init(type: .menu)

            let dups = Dictionary(grouping: self.menuItems, by: { $0.key }).filter { $1.count > 1 }.keys
            if !dups.isEmpty {
                fatalError("Duplicated keys: \(dups)")
            }
        }

    #endif

//    public init() {
//        self.menuItems = [MenuItem]()
//        self.showMenu = false
//        self.autoClose = false
//        self.openButtonAtTop = false
//        self.openButtonColor = Color(NSColor.labelColor)
//        self.openButtonIcon = ""
//        self.openButtonSize = 0.0
//        self.sideTitleView = nil
//        self.backgroundColor = Color(NSColor.windowBackgroundColor)
//        self.itemsColor = .red
//        self.selectedItemBackgroundColor = .gray
//        self.titleView = nil
//        self.titleViewBackgroundColor = Color(NSColor.labelColor)
//        self.inspector = nil
//        self.currentTab = 0
//    }

    public func addItem(item: MenuItem) {
        menuItems.append(item)
        if menuItems.count == 1 {
            currentTab = menuItems[0].key
        }
        let dups = Dictionary(grouping: menuItems, by: { $0.key }).filter { $1.count > 1 }.keys
        if !dups.isEmpty {
            fatalError("Duplicated keys: \(dups)")
        }
    }
    
    public func deleteItemAt(index: Int) {
        menuItems.remove(at: index)
    }

    public func deleteItemsFrom(index: Int) {
        menuItems.removeSubrange((index...))
    }

    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case autoClose
        case menuItems
        case openButtonAtTop
        case openButtonColor
        case openButtonIcon
        case openButtonSize
        case backgroundColor
        case itemsColor
        case selectedItemBackgroundColor
        case titleViewBackgroundColor
    }

    enum ArrayKeys: CodingKey {
        case menuItems
    }

    enum ClassTypeKey: CodingKey {
        case type
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        autoClose = try values.decode(Bool.self, forKey: .autoClose)
        // let items = try values.decode([MenuItem].self, forKey: .menuItems)

        let container = try decoder.container(keyedBy: ArrayKeys.self)

        var menuItemsArrayForType = try container.nestedUnkeyedContainer(forKey: ArrayKeys.menuItems)
        var menuItems = [MenuItem]()
        var menuItemsArray = menuItemsArrayForType
        while !menuItemsArrayForType.isAtEnd {
            let menuItem = try menuItemsArrayForType.nestedContainer(keyedBy: ClassTypeKey.self)
            let type = try menuItem.decode(MenuItemType.self, forKey: ClassTypeKey.type)
            switch type {
            case .item:
                menuItems.append(try menuItemsArray.decode(MenuView.self))

            case .action:
                menuItems.append(try menuItemsArray.decode(MenuAction.self))

            case .divider:
                menuItems.append(try menuItemsArray.decode(MenuDivider.self))

            case .spacer:
                menuItems.append(try menuItemsArray.decode(MenuSpacer.self))
            }
        }
        self.menuItems = menuItems

        openButtonAtTop = try values.decode(Bool.self, forKey: .openButtonAtTop)
        openButtonColor = try values.decode(Color.self, forKey: .openButtonColor)
        openButtonIcon = try values.decode(String.self, forKey: .openButtonIcon)
        openButtonSize = try values.decode(CGFloat.self, forKey: .openButtonSize)
        backgroundColor = try values.decode(Color.self, forKey: .backgroundColor)
        itemsColor = try values.decode(Color.self, forKey: .itemsColor)
        selectedItemBackgroundColor = try values.decode(Color.self, forKey: .selectedItemBackgroundColor)
        titleViewBackgroundColor = try values.decode(Color.self, forKey: .titleViewBackgroundColor)

        showMenu = false
        sideTitleView = nil
        titleView = nil
        inspector = nil
        currentTab = menuItems[0].key
        super.init(type: .menu)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(autoClose, forKey: .autoClose)
        try container.encode(menuItems, forKey: .menuItems)
        try container.encode(openButtonAtTop, forKey: .openButtonAtTop)
        try container.encode(openButtonColor, forKey: .openButtonColor)
        try container.encode(openButtonIcon, forKey: .openButtonIcon)
        try container.encode(openButtonSize, forKey: .openButtonSize)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(itemsColor, forKey: .itemsColor)
        try container.encode(selectedItemBackgroundColor, forKey: .selectedItemBackgroundColor)
        try container.encode(titleViewBackgroundColor, forKey: .titleViewBackgroundColor)
        try super.encode(to: encoder)
    }
}
