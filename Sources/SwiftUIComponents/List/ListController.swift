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

public struct ListAction: Hashable, Codable {
    public var key: String
    public var label: String
    public var color: Color
    public var systemIcon: String?
    public var icon: String?

    #if os(iOS)
        public init(key: String, label: String, systemIcon: String? = nil, icon: String? = nil, color: Color = Color(uiColor: .label)) {
            self.key = key
            self.label = label
            self.color = color
            self.systemIcon = systemIcon
            self.icon = icon
        }
    #endif
    #if os(macOS)
        public init(key: String, label: String, systemIcon: String? = nil, icon: String? = nil, color: Color = Color(.labelColor)) {
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
    public enum ListStyle: Codable {
        case plain(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case grouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case inset(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case insetGrouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
        case sidebar(alternatesRows: Bool, alternateBackgroundColor: Color = Color(uiColor: UIColor.systemBackground))
    }
#endif
#if os(macOS)
    public enum ListStyle: Codable {
        case plain(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor))
        case grouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor)) // On macOS like inset
        case inset(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor))
        case insetGrouped(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor)) // On macOS like inset
        case sidebar(alternatesRows: Bool, alternateBackgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor))
    }
#endif

public class ListController<Item: Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: SuperController, ObservableObject {
    @Published var items: [Item]
    var sort: ((_: inout [Item]) -> Void)?
    @Published public var style: ListStyle
    @Published public var title: String?
    @Published public var multipleSelection: Bool
    @Published public var addButtonIcon: String
    @Published public var addButtonColor: Color
    @Published public var editButtonLabel: String
    @Published public var deleteButtonLabel: String
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
                    addButtonIcon: String = "plus.square",
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

            super.init(type: .list)

            if (!leadingActions.isEmpty || !trailingActions.isEmpty) && self.actionHandler == nil {
                fatalError("No actiton Handler provided")
            }

            if sort != nil {
                sort!(&self.items)
            }
        }

        required init(from decoder: Decoder) throws {
            fatalError("init(from:) has not been implemented")
        }
    #endif

    #if os(macOS)

        public init(items: [Item],
                    sort: ((_: inout [Item]) -> Void)? = nil,
                    style: ListStyle,
                    title: String? = nil,
                    multipleSelection: Bool = false,
                    addButtonIcon: String = "plus.square",
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
            super.init(type: .list)
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

    public func addLeadingAction(action: ListAction) {
        leadingActions.append(action)
    }

    public func addTrailingAction(action: ListAction) {
        trailingActions.append(action)
    }

    public func deleteLeadingAction(action: ListAction) {
        if let idx = leadingActions.firstIndex(of: action) {
            leadingActions.remove(at: idx)
        }
    }

    public func deleteTrailingAction(action: ListAction) {
        if let idx = trailingActions.firstIndex(of: action) {
            trailingActions.remove(at: idx)
        }
    }

    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case style
        case title
        case multipleSelection
        case addButtonIcon
        case addButtonColor
        case editButtonLabel
        case deleteButtonLabel
        case backgroundColor
        case rowBackgroundColor
        case swipeActions
        case leadingActions
        case trailingActions
        case showLineSeparator
        case lineSeparatorColor
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        items = [Item]()
        style = try values.decode(ListStyle.self, forKey: .style)
        multipleSelection = try values.decode(Bool.self, forKey: .multipleSelection)
        title = try? values.decode(String.self, forKey: .title)
        addButtonIcon = try values.decode(String.self, forKey: .addButtonIcon)
        addButtonColor = try values.decode(Color.self, forKey: .addButtonColor)
        editButtonLabel = try values.decode(String.self, forKey: .editButtonLabel)
        deleteButtonLabel = try values.decode(String.self, forKey: .deleteButtonLabel)
        backgroundColor = try values.decode(Color.self, forKey: .backgroundColor)
        rowBackgroundColor = try values.decode(Color.self, forKey: .rowBackgroundColor)
        swipeActions = try values.decode(Bool.self, forKey: .swipeActions)
        leadingActions = try values.decode([ListAction].self, forKey: .leadingActions)
        trailingActions = try values.decode([ListAction].self, forKey: .trailingActions)
        showLineSeparator = try values.decode(Bool.self, forKey: .showLineSeparator)
        lineSeparatorColor = try? values.decode(Bool.self, forKey: .lineSeparatorColor)
        makeRow = { _ in
            fatalError("What about this?")
        }
        super.init(type: .list)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(style, forKey: .style)
        try container.encode(multipleSelection, forKey: .multipleSelection)
        try container.encode(title, forKey: .title)
        try container.encode(addButtonIcon, forKey: .addButtonIcon)
        try container.encode(addButtonColor, forKey: .addButtonColor)
        try container.encode(editButtonLabel, forKey: .editButtonLabel)
        try container.encode(deleteButtonLabel, forKey: .deleteButtonLabel)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(rowBackgroundColor, forKey: .rowBackgroundColor)
        try container.encode(swipeActions, forKey: .swipeActions)
        try container.encode(leadingActions, forKey: .leadingActions)
        
        try container.encode(leadingActions, forKey: .leadingActions)
        try container.encode(trailingActions, forKey: .trailingActions)
        try container.encode(showLineSeparator, forKey: .showLineSeparator)
        try container.encode(lineSeparatorColor, forKey: .lineSeparatorColor)
        
        try super.encode(to: encoder)
    }
}
