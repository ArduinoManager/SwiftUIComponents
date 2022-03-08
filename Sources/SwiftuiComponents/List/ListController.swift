//
//  SuperListViewModel.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/3/22.
//

import Foundation
import SwiftUI
import Combine

public protocol ListItemSelectable {
    func isSelected() -> Bool
    func deselect()
    func select()
    func toggleSelection()
}

public protocol ListItemCopyable: AnyObject {
    init(copy: Self)
}

public class ListController<Item: Equatable & ListItemSelectable, Row: View, Form: View>: ObservableObject {
    @Published var items: [Item]
    var makeRow: (_: Item) -> Row
    var makeForm: ((_: SheetMode, _: Item?) -> Form)!
    
    public init(items: [Item], makeRow: @escaping (_: Item) -> Row) {
        self.items = items
        self.makeRow = makeRow
    }
    
    public func addFormBuilder(makeForm: @escaping (_: SheetMode, _: Item?) -> Form) {
        self.makeForm = makeForm
    }
    
    public var selectedItems: [Item] {
        get {
            items.filter({$0.isSelected()})
        }
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
        items.forEach{$0.deselect()} // Remove for multiple selection !
        let newItem = item
        newItem.toggleSelection()
        update(oldItem: item, newItem: newItem)
    }
}


