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
    public var color: GenericColor
    public var systemIcon: String?
    public var icon: String?

    #if os(iOS)
        public init(key: String, label: String, systemIcon: String? = nil, icon: String? = nil, color: GenericColor = GenericColor.systemLabel) {
            self.key = key
            self.label = label
            self.color = color
            self.systemIcon = systemIcon
            self.icon = icon
        }
    #endif
    #if os(macOS)
        public init(key: String, label: String, systemIcon: String? = nil, icon: String? = nil, color: GenericColor = GenericColor.systemLabel) {
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

    public static func == (lhs: ListAction, rhs: ListAction) -> Bool {
        return lhs.key == rhs.key
    }
}

public enum ListComponentStyle: Codable {
    case plain(alternatesRows: Bool, alternateBackgroundColor: GenericColor = GenericColor.systemLabel)
    case grouped(alternatesRows: Bool, alternateBackgroundColor: GenericColor = GenericColor.systemLabel) // On macOS like inset
    case inset(alternatesRows: Bool, alternateBackgroundColor: GenericColor = GenericColor.systemLabel)
    case insetGrouped(alternatesRows: Bool, alternateBackgroundColor: GenericColor = GenericColor.systemLabel) // On macOS like inset
    case sidebar(alternatesRows: Bool, alternateBackgroundColor: GenericColor = GenericColor.systemLabel)
}

public enum EventType {
    case willAddItem
    case willEditItem
    case willDeleteItem
}

public enum FormMode: String {
    case new
    case edit
}

public struct SelectedAction<Item> {
    public var key: String
    public var item: Item
}

open class ListController<Item: Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: SuperController, ObservableObject {
    @Published open var items: [Item]
    @Published public var style: ListComponentStyle
    @Published public var multipleSelection: Bool
    @Published public var addButtonIcon: String
    @Published public var addButtonColor: GenericColor
    @Published public var editButtonLabel: String
    @Published public var deleteButtonLabel: String
    @Published public var backgroundColor: GenericColor
    @Published public var rowBackgroundColor: GenericColor
    @Published public var swipeActions: Bool
    @Published public var leadingActions: [ListAction]
    @Published public var trailingActions: [ListAction]
    @Published public var selectedAction: SelectedAction<Item>?
    @Published public var showLineSeparator: Bool
    @Published public var lineSeparatorColor: GenericColor?
    public var makeRow: (_: Item) -> Row
    public var editingItem: Item? {
        didSet {
            if editingItem == nil {
                formItem = Item()
            } else {
                formItem = Item(copy: editingItem!)
            }
        }
    }

    public var itemsEventsHandler: ((_ operation: EventType, _ item: Item) -> Bool)?

    /// Item associated to the form for entering a new Item or editing an existing one
    ///
    @Published public var formItem: Item!

    /// When true for a NavigationList, the form to eneter a new item is shown in the right panel.
    /// Unused for a SimpleList
    @Published var startNewItem: Bool = false

    public var isPlain: Bool {
        if case .plain = style {
            return true
        }
        return false
    }

    #if os(iOS)
        public init(items: [Item],
                    style: ListComponentStyle,
                    multipleSelection: Bool = false,
                    addButtonIcon: String = "plus",
                    addButtonColor: GenericColor = GenericColor.systemLabel,
                    editButtonLabel: String,
                    deleteButtonLabel: String,
                    backgroundColor: GenericColor = GenericColor.systemBackground,
                    rowBackgroundColor: GenericColor = GenericColor.systemBackground,
                    swipeActions: Bool = true,
                    leadingActions: [ListAction] = [],
                    trailingActions: [ListAction] = [],
                    showLineSeparator: Bool = true,
                    lineSeparatorColor: GenericColor? = nil,
                    itemsEventsHandler: ((_ operation: EventType, _ item: Item) -> Bool)? = nil,
                    makeRow: @escaping (_: Item) -> Row
        ) {
            self.items = items
            self.style = style
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
            self.showLineSeparator = showLineSeparator
            self.lineSeparatorColor = lineSeparatorColor
            self.makeRow = makeRow
            self.itemsEventsHandler = itemsEventsHandler
            super.init(type: .list)

            sortItems()
        }
    #endif

    #if os(macOS)

        public init(items: [Item],
                    style: ListComponentStyle,
                    multipleSelection: Bool = false,
                    addButtonIcon: String = "plus",
                    addButtonColor: GenericColor = GenericColor.systemLabel,
                    editButtonLabel: String,
                    deleteButtonLabel: String,
                    backgroundColor: GenericColor = GenericColor.systemBackground,
                    rowBackgroundColor: GenericColor = GenericColor.systemBackground,
                    swipeActions: Bool = true,
                    leadingActions: [ListAction] = [],
                    trailingActions: [ListAction] = [],
                    showLineSeparator: Bool = true,
                    lineSeparatorColor: GenericColor? = nil,
                    itemsEventsHandler: ((_ operation: EventType, _ item: Item) -> Bool)? = nil,
                    makeRow: @escaping (_: Item) -> Row
        ) {
            self.items = items
            self.style = style
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
            self.showLineSeparator = showLineSeparator
            self.lineSeparatorColor = lineSeparatorColor
            self.makeRow = makeRow
            self.itemsEventsHandler = itemsEventsHandler
            super.init(type: .list)

            sortItems()
        }

    #endif

    public lazy var selectedItems: AnyPublisher<[Item], Never> = {
        $items.map { x in
            x.filter({ $0.isSelected() })
        }
        .eraseToAnyPublisher()
    }()

    /// Add a new Item to the list
    /// - Parameters:
    ///   - item: item to add
    ///   - callEventsHandler: if false the itemsEventHandler is not called before adding the item
    public func add(item: Item, callEventsHandler: Bool = true) {
        var abort = false
        if let eventsHandler = itemsEventsHandler, callEventsHandler {
            abort = !eventsHandler(.willAddItem, item)
        }
        if !abort {
            items.append(item)
            sortItems()
        }
    }

    /// Add a new Items to the list
    /// - Parameters:
    ///   - item: item to add
    ///   - callEventsHandler: if false the itemsEventHandler is not called before adding each item
    public func add(items: [Item], callEventsHandler: Bool = true) {
        if !callEventsHandler {
            self.items.append(contentsOf: items)
            sortItems()
            return
        }

        for newItem in items {
            add(item: newItem, callEventsHandler: callEventsHandler)
        }
    }

    /// Update an existing item
    /// - Parameters:
    ///   - oldItem: item to update
    ///   - newItem: updating item
    ///   - callEventsHandler: if false the itemsEventHandler is not called before editing the item
    public func update(oldItem: Item, newItem: Item, callEventsHandler: Bool = true) {
        var abort = false
        if let eventsHandler = itemsEventsHandler, callEventsHandler {
            abort = !eventsHandler(.willEditItem, newItem)
        }
        if !abort {
            updateWithoutHandler(oldItem: oldItem, newItem: newItem)
        }
    }
    
    /// Delete an item from the list
    /// - Parameters:
    ///   - item: item to delete
    ///   - callEventsHandler: if false the itemsEventHandler is not called before deleting the item
    func delete(item: Item, callEventsHandler: Bool = true) {
        var abort = false
        if let eventsHandler = itemsEventsHandler, callEventsHandler {
            abort = !eventsHandler(.willDeleteItem, item)
        }

        if !abort, let idx = items.firstIndex(of: item) {
            items.remove(at: idx)
        }
    }

    private func updateWithoutHandler(oldItem: Item, newItem: Item) {
        if let idx = items.firstIndex(of: oldItem) {
            items.remove(at: idx)
            items.insert(newItem, at: idx)
            sortItems()
        }
    }

    func select(item: Item) {
        if !multipleSelection {
            items.filter({ $0 != item }).forEach { $0.deselect() }
        }
        let newItem = item
        newItem.toggleSelection()
        updateWithoutHandler(oldItem: item, newItem: newItem)
    }

    public func completeFormAction() {
        if editingItem == nil {
            add(item: formItem)
            startNewItem = false
        } else {
            update(oldItem: editingItem!, newItem: formItem)
            startNewItem = false
        }
    }

    public func cancelForm() {
        startNewItem = false
        editingItem = nil
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

    open func headerProvider() -> AnyView? {
        return nil
    }

    open func footerProvider() -> AnyView? {
        return nil
    }

    open func sortItems() {
    }

    // MARK: - Encodable & Decodable

    enum CodingKeys: CodingKey {
        case style
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
        style = try values.decode(ListComponentStyle.self, forKey: .style)
        multipleSelection = try values.decode(Bool.self, forKey: .multipleSelection)
        addButtonIcon = try values.decode(String.self, forKey: .addButtonIcon)
        addButtonColor = try values.decode(GenericColor.self, forKey: .addButtonColor)
        editButtonLabel = try values.decode(String.self, forKey: .editButtonLabel)
        deleteButtonLabel = try values.decode(String.self, forKey: .deleteButtonLabel)
        backgroundColor = try values.decode(GenericColor.self, forKey: .backgroundColor)
        rowBackgroundColor = try values.decode(GenericColor.self, forKey: .rowBackgroundColor)
        swipeActions = try values.decode(Bool.self, forKey: .swipeActions)
        leadingActions = try values.decode([ListAction].self, forKey: .leadingActions)
        trailingActions = try values.decode([ListAction].self, forKey: .trailingActions)
        showLineSeparator = try values.decode(Bool.self, forKey: .showLineSeparator)
        lineSeparatorColor = try? values.decode(GenericColor.self, forKey: .lineSeparatorColor)
        makeRow = { _ in
            fatalError("What about this?")
        }
        super.init(type: .list)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(style, forKey: .style)
        try container.encode(multipleSelection, forKey: .multipleSelection)
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
