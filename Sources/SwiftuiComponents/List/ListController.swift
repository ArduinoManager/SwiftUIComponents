//
//  SuperListViewModel.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/3/22.
//

import Foundation
import SwiftUI
import Combine

public protocol Selectable {
    func isSelected() -> Bool
    func deselect()
    func select()
    func toggleSelection()
}

public protocol Copyable: AnyObject {
    init(copy: Self)
}

public class ItemClass:ObservableObject, Identifiable, Equatable, CustomDebugStringConvertible, Selectable, Copyable {
    
    public let id = UUID()
    @Published var selected = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    public required init() {
        self.firstName = ""
        self.lastName = ""
    }
    
    public required init(copy: ItemClass) {
        self.firstName = copy.firstName
        self.lastName = copy.lastName
    }
    
    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    public func isSelected() -> Bool {
        return selected
    }
    
    public func deselect() {
        selected = false
    }
    
    public func select() {
        selected = true
    }
    public func toggleSelection() {
        selected.toggle()
    }
    
    public static func == (lhs: ItemClass, rhs: ItemClass) -> Bool {
        return lhs.id == rhs.id
    }

    public var debugDescription: String {
        return "\(firstName) \(lastName)"
    }    
}

public class ListController<T: Equatable & Selectable>: ObservableObject {
    @Published var items: [T]
    
    public init(items: [T]) {
        self.items = items
    }
    
    var selectedItems: [T] {
        get {
            items.filter({$0.isSelected()})
        }
    }
    
    func delete(item: T) {
        if let idx = items.firstIndex(of: item) {
            items.remove(at: idx)
        }
    }
    
    func add(item: T) {
        items.append(item)
    }
    
    func update(oldItem: T, newItem: T) {
        if let idx = items.firstIndex(of: oldItem) {
            items.remove(at: idx)
            items.insert(newItem, at: idx)
            print(items)
        }
    }
    
    func select(item: T) {
        items.forEach{$0.deselect()} // Remove for multiple selection !
        let newItem = item
        newItem.toggleSelection()
        update(oldItem: item, newItem: newItem)
    }
}
