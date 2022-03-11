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
    var key: String
    var label: String
    var color: Color
    
    #if os(iOS)
    public init(key: String, label: String, color: Color = Color(uiColor: .label)) {
        self.key = key
        self.label = label
        self.color = color
    }
    #endif
    #if os(macOS)
    public init(key: String, label: String, color: Color = Color(NSColor.labelColor)) {
        self.key = key
        self.label = label
        self.color = color
    }
    #endif
}

public enum ListStyle {
    case plain
    case grouped
    case inset
    case insetGrouped
    case sidebar
}

public class ListController<Item: Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ObservableObject {
    @Published var items: [Item]
    var style: ListStyle
    var title: String?
    var multipleSelection: Bool
    var addButtonIcon: Image
    var addButtonColor: Color
    var editButtonLabel: String
    var deleteButtonLabel: String
    var backgroundColor: Color
    var rowBackgroundColor: Color
    var leadingActions: [ListAction]
    var trailingActions: [ListAction]
    var actionHandler: ((_ actionKey: String) -> Void)?
    var showLineSeparator: Bool
    var lineSeparatorColor: Color?
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

    #if os(iOS)
    public init(items: [Item],
                style: ListStyle,
                title: String? = nil,
                multipleSelection: Bool = false,
                addButtonIcon: Image = Image(systemName: "plus.square"),
                addButtonColor: Color = Color(uiColor: .label),
                editButtonLabel: String,
                deleteButtonLabel: String,
                backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
                rowBackgroundColor: Color = Color(uiColor: .systemBackground),
                leadingActions: [ListAction] = [],
                trailingActions: [ListAction] = [],
                actionHandler: ((_ actionKey: String) -> Void)? = nil,
                showLineSeparator: Bool = true,
                lineSeparatorColor: Color? = nil,
                makeRow: @escaping (_: Item) -> Row
                
    )
    {
        self.items = items
        self.style = style
        self.title = title
        self.multipleSelection = multipleSelection
        self.addButtonIcon = addButtonIcon
        self.addButtonColor = addButtonColor
        self.editButtonLabel = editButtonLabel
        self.deleteButtonLabel = deleteButtonLabel
        self.backgroundColor = backgroundColor
        self.rowBackgroundColor = rowBackgroundColor
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.actionHandler = actionHandler
        self.showLineSeparator = showLineSeparator
        self.lineSeparatorColor = lineSeparatorColor
        self.makeRow = makeRow
        if (!leadingActions.isEmpty || !trailingActions.isEmpty) && self.actionHandler == nil{
            fatalError("No actiton Handler provided")
        }
    }
    #endif
    
    #if os(macOS)
    
    public init(items: [Item],
                style: ListStyle,
                title: String? = nil,
                multipleSelection: Bool = false,
                addButtonIcon: Image = Image(systemName: "plus.square"),
                addButtonColor: Color = Color(NSColor.labelColor),
                editButtonLabel: String,
                deleteButtonLabel: String,
                backgroundColor: Color = Color(NSColor.windowBackgroundColor),
                rowBackgroundColor: Color = Color(NSColor.windowBackgroundColor),
                leadingActions: [ListAction] = [],
                trailingActions: [ListAction] = [],
                actionHandler: ((_ actionKey: String) -> Void)? = nil,
                showLineSeparator: Bool = true,
                lineSeparatorColor: Color? = nil,
                makeRow: @escaping (_: Item) -> Row
                
    )
    {
        self.items = items
        self.style = style
        self.title = title
        self.multipleSelection = multipleSelection
        self.addButtonIcon = addButtonIcon
        self.addButtonColor = addButtonColor
        self.editButtonLabel = editButtonLabel
        self.deleteButtonLabel = deleteButtonLabel
        self.backgroundColor = backgroundColor
        self.rowBackgroundColor = rowBackgroundColor
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.actionHandler = actionHandler
        self.showLineSeparator = showLineSeparator
        self.lineSeparatorColor = lineSeparatorColor
        self.makeRow = makeRow
        if (!leadingActions.isEmpty || !trailingActions.isEmpty) && self.actionHandler == nil{
            fatalError("No actiton Handler provided")
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
    }

    public func update(oldItem: Item, newItem: Item) {
        if let idx = items.firstIndex(of: oldItem) {
            items.remove(at: idx)
            items.insert(newItem, at: idx)
            print(items)
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
        } else {
            update(oldItem: editingItem!, newItem: formItem)
        }
    }
}