//
//  SuperListViewModel.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/3/22.
//

import Combine
import Foundation
import SwiftUI

public protocol ListItemSelectable {
    func isSelected() -> Bool
    func deselect()
    func select()
    func toggleSelection()
}

public protocol ListItemCopyable: AnyObject {
    init(copy: Self)
}

public class ListController<Item: Equatable & ListItemSelectable, Row: View>: ObservableObject {
    @Published var items: [Item]
    var title: String?
    var multipleSelection: Bool
    var addButtonIcon: Image
    var addButtonColor: Color
    var backgroundColor: Color
    var rowBackgroundColor: Color
    var makeRow: (_: Item) -> Row
    public var formItem: Item?
    public var mode: SheetMode = .none

    public init(items: [Item],
                title: String? = nil,
                multipleSelection: Bool = false,
                addButtonIcon: Image = Image(systemName: "plus.square"),
                addButtonColor: Color = Color(uiColor: .label),
                backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
                rowBackgroundColor: Color = Color(uiColor: .systemBackground),
                makeRow: @escaping (_: Item) -> Row
    ) {
        self.items = items
        self.title = title
        self.multipleSelection = multipleSelection
        self.addButtonIcon = addButtonIcon
        self.addButtonColor = addButtonColor
        self.backgroundColor = backgroundColor
        self.rowBackgroundColor = rowBackgroundColor
        self.makeRow = makeRow
    }

//    public func addFormBuilder(makeForm: @escaping (_: SheetMode, _: Item?) -> Form) {
//        self.makeForm = makeForm
//    }

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

    public func handlingFormAction(item: Item) {
        if formItem == nil {
            add(item: item)
        } else {
            update(oldItem: formItem!, newItem: item)
        }
    }
}
