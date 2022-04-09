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
    public var sideTitleViewProvider: ((_ controller: MenuController) -> AnyView)?
    @Published public var itemsColor: GenericColor
    @Published public var selectedItemBackgroundColor: GenericColor
    @Published public var backgroundColor: GenericColor
    @Published public var autoClose: Bool
    @Published public var openButtonAtTop: Bool
    @Published public var openButtonColor: GenericColor
    @Published public var openButtonIcon: String
    @Published public var openButtonSize: CGFloat
    public var titleViewProvider: ((_ controller: MenuController) -> AnyView)?
    @Published public var titleViewBackgroundColor: GenericColor
    @Published public var menuItems: [MenuItem]
    public var actionsHandler: ((_ controller: MenuController, _ item: MenuAction) -> Void)?
    public var viewProvider: ((_ controller: MenuController, _ item: MenuView) -> AnyView)?
    public var inspectorViewProvider: ((_ controller: MenuController) -> AnyView?)?
    var boostrap: String? = "A"
    public var menuViews: [MenuView] {
        return menuItems.filter({$0.type == .item}) as! [MenuView]
    }
    
    #if os(iOS)

        public init(menuItems: [MenuItem],
                    autoClose: Bool = true,
                    openButtonAtTop: Bool = true,
                    openButtonColor: GenericColor = .systemLabel,
                    openButtonIcon: String = "line.3.horizontal",
                    openButtonSize: CGFloat = 20.0,
                    sideTitleViewProvider: ((_ controller: MenuController) -> AnyView)? = nil,
                    backgroundColor: GenericColor = .systemBackground,
                    itemsColor: GenericColor = .systemLabel,
                    selectedItemBackgroundColor: GenericColor = GenericColor(systemColor: .systemGray4),
                    titleViewProvider: ((_ controller: MenuController) -> AnyView)?,
                    titleViewBackgroundColor: GenericColor = .systemBackground,
                    actionsHandler: @escaping (_ controller: MenuController, _ item: MenuAction) -> Void,
                    viewProvider: ((_ controller: MenuController, _ item: MenuView) -> AnyView)?) {
            showMenu = false
            self.menuItems = menuItems
            self.autoClose = autoClose
            self.openButtonAtTop = openButtonAtTop
            self.openButtonColor = openButtonColor
            self.openButtonIcon = openButtonIcon
            self.openButtonSize = openButtonSize
            self.sideTitleViewProvider = sideTitleViewProvider
            self.backgroundColor = backgroundColor
            self.itemsColor = itemsColor
            self.selectedItemBackgroundColor = selectedItemBackgroundColor
            self.titleViewProvider = titleViewProvider
            self.titleViewBackgroundColor = titleViewBackgroundColor
            self.actionsHandler = actionsHandler
            self.viewProvider = viewProvider
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
                    sideTitleViewProvider: ((_ controller: MenuController) -> AnyView)? = nil,
                    backgroundColor: GenericColor = .systemBackground,
                    itemsColor: GenericColor = .systemLabel,
                    titleViewProvider: ((_ controller: MenuController) -> AnyView)?,
                    titleViewBackgroundColor: GenericColor = .systemBackground,
                    inspectorViewProvider: ((_ controller: MenuController) -> AnyView?)? = nil,
                    actionsHandler: @escaping (_ controller: MenuController, _ item: MenuAction) -> Void,
                    viewProvider: ((_ controller: MenuController, _ item: MenuView) -> AnyView)?) {
            
            showMenu = false
            self.menuItems = menuItems
            autoClose = true
            openButtonAtTop = false
            openButtonColor = .systemLabel
            openButtonIcon = "line.3.horizontal"
            openButtonSize = 20.0
            self.sideTitleViewProvider = sideTitleViewProvider
            self.backgroundColor = backgroundColor
            self.itemsColor = itemsColor
            self.selectedItemBackgroundColor = GenericColor(systemColor: .systemGray4)
            self.titleViewProvider = titleViewProvider
            self.titleViewBackgroundColor = titleViewBackgroundColor
            self.inspectorViewProvider = inspectorViewProvider
            self.actionsHandler = actionsHandler
            self.viewProvider = viewProvider
            currentTab = menuItems[0].key

            super.init(type: .menu)

            let dups = Dictionary(grouping: self.menuItems, by: { $0.key }).filter { $1.count > 1 }.keys
            if !dups.isEmpty {
                fatalError("Duplicated keys: \(dups)")
            }
        }

    #endif

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

//    func makeView(item: MenuView) -> some View {
//        return viewProvider?(self,item)
//    }
    
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
        openButtonColor = try values.decode(GenericColor.self, forKey: .openButtonColor)
        openButtonIcon = try values.decode(String.self, forKey: .openButtonIcon)
        openButtonSize = try values.decode(CGFloat.self, forKey: .openButtonSize)
        backgroundColor = try values.decode(GenericColor.self, forKey: .backgroundColor)
        itemsColor = try values.decode(GenericColor.self, forKey: .itemsColor)
        selectedItemBackgroundColor = try values.decode(GenericColor.self, forKey: .selectedItemBackgroundColor)
        titleViewBackgroundColor = try values.decode(GenericColor.self, forKey: .titleViewBackgroundColor)

        showMenu = false
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
