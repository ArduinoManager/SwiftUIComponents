//
//  SuperListViewModel.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/3/22.
//

import Combine
import Foundation
import SwiftUI

public protocol ListItemInitializable {
    init()
}

public protocol ListItemSelectable {
    func isSelected() -> Bool
    func deselect()
    func select()
    func toggleSelection()
}

public protocol ListItemCopyable: AnyObject {
    init(copy: Self)
}

public struct ListAction: Hashable {
    public var key: String
    public var label: String
    public var color: Color
    public var systemIcon: String?
    public var icon: Image?

    #if os(iOS)
        public init(key: String, label: String, systemIcon: String? = nil, icon: Image? = nil, color: Color = Color(uiColor: .label)) {
            self.key = key
            self.label = label
            self.color = color
            self.systemIcon = systemIcon
            self.icon = icon
        }
    #endif
    #if os(macOS)
        public init(key: String, label: String, systemIcon: String? = nil, icon: Image? = nil, color: Color = Color(NSColor.labelColor)) {
            self.key = key
            self.label = label
            self.color = color
            self.systemIcon = systemIcon
            self.icon = icon
        }
    #endif

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

#if os(iOS)
    public enum ListStyle {
        case plain(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case grouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case inset(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case insetGrouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case sidebar(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
    }
#endif
#if os(macOS)
    public enum ListStyle {
        case plain(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor))
        case grouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor)) // On macOS like inset
        case inset(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor))
        case insetGrouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor)) // On macOS like inset
        case sidebar(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor))

//        public func hash(into hasher: inout Hasher) {
//            switch self {
//            case .plain(alternatesRows: _, alternateBackgroundColor: _):
//                hasher.combine("plain")
//            case .grouped(alternatesRows: _, alternateBackgroundColor: _):
//                hasher.combine("grouped")
//            case .inset(alternatesRows: _, alternateBackgroundColor: _):
//                hasher.combine("inset")
//            case .insetGrouped(alternatesRows: _, alternateBackgroundColor: _):
//                hasher.combine("insetGrouped")
//            case .sidebar(alternatesRows: _, alternateBackgroundColor: _):
//                hasher.combine("sidebar")
//            }
//        }
//
//        public static var allCases: [ListStyle] {
//            return [.plain(alternatesRows: false, alternateBackgroundColor: Color(nsColor: NSColor.windowBackgroundColor)), .grouped(alternatesRows: false, alternateBackgroundColor: Color(nsColor: NSColor.windowBackgroundColor)), .inset(alternatesRows: false, alternateBackgroundColor: Color(nsColor: NSColor.windowBackgroundColor)), .insetGrouped(alternatesRows: false), .sidebar(alternatesRows: false, alternateBackgroundColor: Color(nsColor: NSColor.windowBackgroundColor))]
//        }
    }
#endif

public class ListController<Item: Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ObservableObject {
    @Published var items: [Item]
    var sort: ((_: inout [Item]) -> Void)?
    @Published public var style: ListStyle
    @Published public var title: String?
    @Published public var multipleSelection: Bool
    var addButtonIcon: Image
    var addButtonColor: Color
    var editButtonLabel: String
    var deleteButtonLabel: String
    @Published public var backgroundColor: Color
    @Published public var rowBackgroundColor: Color
    @Published public var swipeActions: Bool
    @Published public var leadingActions: [ListAction]
    @Published public var trailingActions: [ListAction]
    var actionHandler: ((_ actionKey: String) -> Void)?
    @Published public var showLineSeparator: Bool
    @Published public var lineSeparatorColor: Color?
    var makeRow: (_: Item) -> Row
    public var editingItem: Item? {
        didSet {
            if editingItem == nil {
                formItem = Item()
            } else {
                formItem = Item(copy: editingItem!)
            }
        }
    }

    @Published public var formItem: Item!
    @Published var selectedItem: Item? // Used only in the NavigationList to start the Form to enter a new Item or edit an existing one
    @Published var startNewItem: String? // Setting this to newItem a new Item is created

    #if os(iOS)
        public init(items: [Item],
                    sort: ((_: inout [Item]) -> Void)? = nil,
                    style: ListStyle,
                    title: String? = nil,
                    multipleSelection: Bool = false,
                    addButtonIcon: Image = Image(systemName: "plus.square"),
                    addButtonColor: Color = Color(uiColor: .label),
                    editButtonLabel: String,
                    deleteButtonLabel: String,
                    backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
                    rowBackgroundColor: Color = Color(uiColor: .systemBackground),
                    swipeActions: Bool = true,
                    leadingActions: [ListAction] = [],
                    trailingActions: [ListAction] = [],
                    actionHandler: ((_ actionKey: String) -> Void)? = nil,
                    showLineSeparator: Bool = true,
                    lineSeparatorColor: Color? = nil,
                    makeRow: @escaping (_: Item) -> Row
        ) {
            self.items = items
            self.sort = sort
            self.style = style
            self.title = title
            self.multipleSelection = multipleSelection
            self.addButtonIcon = addButtonIcon
            self.addButtonColor = addButtonColor
            self.editButtonLabel = editButtonLabel
            self.deleteButtonLabel = deleteButtonLabel
            self.backgroundColor = backgroundColor
            self.rowBackgroundColor = rowBackgroundColor
            self.swipeActions = swipeActions
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.actionHandler = actionHandler
            self.showLineSeparator = showLineSeparator
            self.lineSeparatorColor = lineSeparatorColor
            self.makeRow = makeRow
            if (!leadingActions.isEmpty || !trailingActions.isEmpty) && self.actionHandler == nil {
                fatalError("No actiton Handler provided")
            }
        }
    #endif

    #if os(macOS)

        public init(items: [Item],
                    sort: ((_: inout [Item]) -> Void)? = nil,
                    style: ListStyle,
                    title: String? = nil,
                    multipleSelection: Bool = false,
                    addButtonIcon: Image = Image(systemName: "plus.square"),
                    addButtonColor: Color = Color(NSColor.labelColor),
                    editButtonLabel: String,
                    deleteButtonLabel: String,
                    backgroundColor: Color = Color(NSColor.windowBackgroundColor),
                    rowBackgroundColor: Color = Color(NSColor.windowBackgroundColor),
                    swipeActions: Bool = true,
                    leadingActions: [ListAction] = [],
                    trailingActions: [ListAction] = [],
                    actionHandler: ((_ actionKey: String) -> Void)? = nil,
                    showLineSeparator: Bool = true,
                    lineSeparatorColor: Color? = nil,
                    makeRow: @escaping (_: Item) -> Row
        ) {
            self.items = items
            self.sort = sort
            self.style = style
            self.title = title
            self.multipleSelection = multipleSelection
            self.addButtonIcon = addButtonIcon
            self.addButtonColor = addButtonColor
            self.editButtonLabel = editButtonLabel
            self.deleteButtonLabel = deleteButtonLabel
            self.backgroundColor = backgroundColor
            self.rowBackgroundColor = rowBackgroundColor
            self.swipeActions = swipeActions
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.actionHandler = actionHandler
            self.showLineSeparator = showLineSeparator
            self.lineSeparatorColor = lineSeparatorColor
            self.makeRow = makeRow
            if (!leadingActions.isEmpty || !trailingActions.isEmpty) && self.actionHandler == nil {
                fatalError("No actiton Handler provided")
            }
            if sort != nil {
                sort!(&self.items)
            }
        }
    #endif
    public var selectedItems: [Item] {
        items.filter({ $0.isSelected() })
    }

    func delete(item: Item) {
        if let idx = items.firstIndex(of: item) {
            items.remove(at: idx)
        }
    }

    public func add(item: Item) {
        items.append(item)
        if sort != nil {
            sort!(&items)
        }
    }

    public func update(oldItem: Item, newItem: Item) {
        if let idx = items.firstIndex(of: oldItem) {
            items.remove(at: idx)
            items.insert(newItem, at: idx)
            // print(items)
            if sort != nil {
                sort!(&items)
            }
        }
    }

    func select(item: Item) {
        if !multipleSelection {
            items.forEach { $0.deselect() }
        }
        let newItem = item
        newItem.toggleSelection()
        update(oldItem: item, newItem: newItem)
    }

    public func completeFormAction() {
        if editingItem == nil {
            add(item: formItem)
            startNewItem = nil
            selectedItem = nil
        } else {
            update(oldItem: editingItem!, newItem: formItem)
            selectedItem = nil
        }
    }

    public func cancelForm() {
        startNewItem = nil
        selectedItem = nil
    }
}
