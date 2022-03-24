//
//  MenuController.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import Foundation
import SwiftUI

public typealias Key = Int

public class MenuItem: Hashable, CustomDebugStringConvertible, Encodable, Decodable {
    public var key: Key
    public var title: String
    public var systemIcon: String?
    public var icon: String?
    public var view: AnyView?
    public var useSystemIcon: Bool

    public init() {
        key = UUID().hashValue
        title = ""
        systemIcon = ""
        useSystemIcon = true
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

    public var debugDescription: String {
        return "[\(key)]"
    }
    
    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case key
        case title
        case icon
        case systemIcon
        case useSystemIcon
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(Int.self, forKey: .key)
        title = try values.decode(String.self, forKey: .title)
        icon = try values.decode(String.self, forKey: .icon)
        systemIcon = try values.decode(String.self, forKey: .systemIcon)
        useSystemIcon = try values.decode(Bool.self, forKey: .useSystemIcon)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(useSystemIcon, forKey: .useSystemIcon)
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
        self.useSystemIcon = true
    }

    public init(key: Key, title: String, icon: String, view: AnyView) {
        super.init()
        self.key = key
        self.title = title
        self.systemIcon = nil
        self.icon = icon
        self.view = view
        self.useSystemIcon = false
    }

    override public var debugDescription: String {
        return "[\(key) Tab \(title)]"
    }
    
    // MARK: - Encodable & Decodable

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
   
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

public class TabMenuSpacer: MenuItem {
    public var spacerHeight: CGFloat?

    public init(height: CGFloat) {
        super.init()
        spacerHeight = height
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case spacerHeight
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        spacerHeight = try values.decode(CGFloat.self, forKey: .spacerHeight)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spacerHeight, forKey: .spacerHeight)
        try super.encode(to: encoder)
    }
}

public class TabMenuDivider: MenuItem {
    public var color: Color

    #if os(iOS)
        public init(color: Color = Color(uiColor: .label)) {
            self.color = color
            super.init()
            title = "\(UUID())"
        }
    #endif

    #if os(macOS)
        public init(color: Color = Color(nsColor: .labelColor)) {
            self.color = color
            super.init()
            title = "\(UUID())"
        }
    #endif
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case color
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        color = try values.decode(Color.self, forKey: .color)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try super.encode(to: encoder)
    }
}

public class TabMenuHandler: MenuItem {
    public var handler: (_ controller: MenuController) -> Void

    public init(title: String, systemIcon: String, handler: @escaping ((_ controller: MenuController) -> Void)) {
        self.handler = handler
        super.init()
        self.title = title
        self.systemIcon = systemIcon
    }

    public init(title: String, icon: String, handler: @escaping ((_ controller: MenuController) -> Void)) {
        self.handler = handler
        super.init()
        self.title = title
        self.systemIcon = nil
        self.icon = icon
    }
    
    override public var debugDescription: String {
        return "[\(key) Handler \(title)]"
    }
    
    // MARK: - Encodable & Decodable
    
    enum CodingKeys: CodingKey {
        case handler
    }
    
    public required init(from decoder: Decoder) throws {
        handler = { controller in
            fatalError("Something went wrong!")
        }
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

public class MenuController: ObservableObject, Encodable, Decodable {
    @Published public var currentTab: Key
    @Published var showMenu: Bool
    @Published var sideTitleView: AnyView?
    @Published public var itemsColor: Color
    @Published public var selectedItemBackgroundColor: Color
    @Published public var backgroundColor: Color
    var autoClose: Bool
    var openButtonAtTop: Bool
    var openButtonColor: Color
    var openButtonIcon: String
    var openButtonSize: CGFloat
    @Published var titleView: AnyView?
    var titleViewBackgroundColor: Color
    @Published public var menuItems: [MenuItem]
    var inspector: AnyView?
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
                    inspector: AnyView? = nil
        ) {
            print(menuItems)

            self.showMenu = false
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
            self.currentTab = menuItems[0].key

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
        let dups = Dictionary(grouping: self.menuItems, by: { $0.key }).filter { $1.count > 1 }.keys
        if !dups.isEmpty {
            fatalError("Duplicated keys: \(dups)")
        }
    }
    
    public func setInspector(inspector: AnyView) {
        self.inspector = inspector
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

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        autoClose = try values.decode(Bool.self, forKey: .autoClose)
        let items = try values.decode([MenuItem].self, forKey: .menuItems)
        menuItems = items
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
        currentTab = items[0].key
    }

    public func encode(to encoder: Encoder) throws {
        
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

        
    }
}
