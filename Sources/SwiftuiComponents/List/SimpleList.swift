//
//  ContentView.swift
//  Shared
//
//  Created by Fabrizio Boco on 3/3/22.
//

import SwiftUI

public enum SheetMode {
    case none
    case edit
    case new
}

class SheetMananger: ObservableObject {
    enum Sheet {
        case Form
    }

    @Published var showSheet = false
    @Published var whichSheet: Sheet? = nil
}

public struct SimpleList<Item: Identifiable & Equatable & Selectable, Row: View, Form: View>: View {
    @ObservedObject var controller: ListController<Item, Row, Form>
    @StateObject var sheetManager = SheetMananger()
    @State var mode: SheetMode = .none
    @State var editingItem: Item?

    public init(controller: ObservedObject<ListController<Item, Row, Form>>) {
        _controller = controller
    }

    public var body: some View {
        VStack {
            HStack {
                Text("Title")
                    .font(.title)
                Spacer()
                Button("Add") {
                    mode = .new
                    editingItem = nil
                    sheetManager.whichSheet = .Form
                    sheetManager.showSheet.toggle()
                }
            }
            .padding([.leading, .trailing])

            List {
                ForEach(controller.items, id: \.id) { item in
                    controller.makeRow(item)
                        .onTapGesture {
                            controller.select(item: item)
                        }
                        .swipeActions {
                            Button("Delete") {
                                print("Delete \(item)")
                                controller.delete(item: item)
                            }
                            .tint(.red)
                            Button("Edit") {
                                print("Edit \(item)")
                                mode = .edit
                                editingItem = item
                                sheetManager.whichSheet = .Form
                                sheetManager.showSheet.toggle()
                            }
                        }
                }
            }
            .sheet(isPresented: $sheetManager.showSheet) {
                if sheetManager.whichSheet == .Form {
                    controller.makeForm(mode, editingItem)

//                    FormView(mode: mode, item: editingItem) { mode, item in
//                        switch mode {
//                        case .none:
//                            break
//                        case .edit:
//                            print("Edit")
//                            controller.update(oldItem: editingItem! as! T, newItem: item! as! T)
//                            editingItem = nil
//                        case .new:
//                            print("New")
//                            controller.add(item: item! as! T)
//                        }
//                    }
                }
            }

            Text("\(controller.selectedItems.debugDescription)")
        }
    }
}

struct FormView: View {
    @Environment(\.presentationMode) var presentationMode
    private var mode: SheetMode
    @StateObject private var item: ItemClass
    private var handler: (_ mode: SheetMode, _ item: ItemClass?) -> Void

    init(mode: SheetMode, item: ItemClass?, handler: @escaping (_ mode: SheetMode, _ item: ItemClass?) -> Void) {
        self.mode = mode

        if item != nil {
            _item = StateObject(wrappedValue: ItemClass(copy: item!))
        } else {
            _item = StateObject(wrappedValue: ItemClass())
        }
        self.handler = handler
    }

    var body: some View {
        VStack {
            Form {
                TextField("", text: $item.firstName)
                TextField("", text: $item.lastName)
                Text("\(item.firstName.count)")
            }

            if mode == .new {
                Text("New")
            }
            if mode == .edit {
                Text("Edit")
            }

            HStack {
                Button("Ok") {
                    handler(mode, item)
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Cancel") {
                    handler(.none, nil)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
    }
}

struct SimpleListContainer: View {
    @ObservedObject private var controller: ListController<ItemClass, MyRow, FormView>

    init() {
        let items = [ItemClass(firstName: "A", lastName: "A"),
                     ItemClass(firstName: "B", lastName: "B"),
                     ItemClass(firstName: "C", lastName: "C")]

        controller = ListController<ItemClass, MyRow, FormView>(items: items, makeRow: { item in
            MyRow(item: item)
        }, makeForm: { mode, item in
            FormView(mode: mode, item: item) { _, _ in
            }
        })
    }

    var body: some View {
        SimpleList(controller: _controller)
    }
}

struct SimpleList_Previews: PreviewProvider {
    static var previews: some View {
        SimpleListContainer()
    }
}

// Auxiliary Preview Functions

struct MyRow: View {
    @ObservedObject var item: ItemClass

    init() {
        _item = ObservedObject(initialValue: ItemClass())
    }

    init(item: ItemClass) {
        _item = ObservedObject(initialValue: item)
    }

    var body: some View {
        HStack {
            Text("\(item.firstName)")
            Text("\(item.lastName)")
        }
        .background(item.selected ? Color.red : Color.clear)
    }
}
