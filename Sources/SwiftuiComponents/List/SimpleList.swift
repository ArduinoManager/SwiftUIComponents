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

public struct SimpleList<Item: Identifiable & Equatable & ListItemSelectable, Row: View, Form: View>: View {
    @ObservedObject var controller: ListController<Item, Row>
    @StateObject var sheetManager = SheetMananger()
//    @State var mode: SheetMode = .none
//    @State var editingItem: Item?

    var form: () -> Form

    public init(controller: ObservedObject<ListController<Item, Row>>, @ViewBuilder form: @escaping () -> Form) {
        _controller = controller
        self.form = form
        UITableView.appearance().backgroundColor = .clear // <-- here
    }

    public var body: some View {
        VStack {
            HStack {
                if let title = controller.title {
                    Text(title)
                        .font(.title)
                }
                Spacer()
                Button {
                    controller.mode = .new
                    controller.formItem = nil
                    sheetManager.whichSheet = .Form
                    sheetManager.showSheet.toggle()
                } label: {
                    controller.addButtonIcon
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .foregroundColor(controller.addButtonColor)
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
                                controller.mode = .edit
                                controller.formItem = item
                                sheetManager.whichSheet = .Form
                                sheetManager.showSheet.toggle()
                            }
                        }
                }
                .listRowBackground(controller.rowBackgroundColor)
            }
            .background(controller.backgroundColor)
            .sheet(isPresented: $sheetManager.showSheet) {
                if sheetManager.whichSheet == .Form {
                    // controller.makeForm(mode, editingItem)
                    form()
                }
            }
        }
    }

//    @ViewBuilder
//    func makeForm() -> some View {
//
//    }
}

// Preview

struct SimpleListContainer: View {
    @ObservedObject private var controller: ListController<ListItem, RowView>

    init() {
        let items = [ListItem(firstName: "A", lastName: "A"),
                     ListItem(firstName: "B", lastName: "B"),
                     ListItem(firstName: "C", lastName: "C")]

//        controller = ListController<ListItem, RowView, FormView>(items: items,
//                                                                 title: "Title",
//                                                                 makeRow: { item in
//                                                                     RowView(item: item)
//                                                                 })

        controller = ListController<ListItem, RowView>(items: items,
                                                       title: "Title",
                                                       addButtonColor: .green,
                                                       backgroundColor: .green,
                                                       rowBackgroundColor: .yellow,
                                                       makeRow: { item in
                                                           RowView(item: item)
                                                       })
    }

    var body: some View {
        SimpleList<ListItem, RowView, MyForm>(controller: _controller) {
            MyForm(controller: _controller)
        }
    }
}

struct SimpleList_Previews: PreviewProvider {
    static var previews: some View {
        SimpleListContainer()
    }
}

// Auxiliary Preview Items

public class ListItem: ObservableObject, Identifiable, Equatable, CustomDebugStringConvertible, ListItemSelectable, ListItemCopyable {
    public let id = UUID()
    @Published var selected = false
    @Published public var firstName: String = ""
    @Published public var lastName: String = ""

    public required init() {
        firstName = ""
        lastName = ""
    }

    public required init(copy: ListItem) {
        firstName = copy.firstName
        lastName = copy.lastName
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

    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.id == rhs.id
    }

    public var debugDescription: String {
        return "\(firstName) \(lastName)"
    }
}

struct RowView: View {
    @ObservedObject var item: ListItem

    init() {
        _item = ObservedObject(initialValue: ListItem())
    }

    init(item: ListItem) {
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

// struct FormContainerView<Form: View>: View {
//    @Environment(\.presentationMode) var presentationMode
//    var form: () -> Form
//
//    init(@ViewBuilder form: @escaping () -> Form) {
//        self.form = form
//    }
//
//    var body: some View {
//        VStack {
//            form()
//        }
//    }
// }

struct MyForm: View {
    @ObservedObject var controller: ListController<ListItem, RowView>
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var item: ListItem

    init(controller: ObservedObject<ListController<ListItem, RowView>>) {
        _controller = controller
        if controller.wrappedValue.formItem != nil {
            _item = StateObject(wrappedValue: ListItem(copy: controller.wrappedValue.formItem!))
        } else {
            _item = StateObject(wrappedValue: ListItem())
        }
    }

    var body: some View {
        VStack {
            Text("MyView")
            Spacer()
            Form {
                TextField("", text: $item.firstName)
                TextField("", text: $item.lastName)
                Text("\(item.firstName.count)")
            }

            if controller.mode == .new {
                Text("New")
            }
            if controller.mode == .edit {
                Text("Edit")
            }

            HStack {
                Button("Ok") {
                    // handler(mode, item)
                    controller.handlingFormAction(item: item)
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
    }
}

// struct FormView: View {
//    @Environment(\.presentationMode) var presentationMode
//    private var mode: SheetMode
//    @StateObject private var item: ListItem
//    private var handler: (_ mode: SheetMode, _ item: ListItem?) -> Void
//
//    init(mode: SheetMode, item: ListItem?, handler: @escaping (_ mode: SheetMode, _ item: ListItem?) -> Void) {
//        self.mode = mode
//
//        if item != nil {
//            _item = StateObject(wrappedValue: ListItem(copy: item!))
//        } else {
//            _item = StateObject(wrappedValue: ListItem())
//        }
//        self.handler = handler
//    }
//
//    var body: some View {
//        VStack {
//            Form {
//                TextField("", text: $item.firstName)
//                TextField("", text: $item.lastName)
//                Text("\(item.firstName.count)")
//            }
//
//            if mode == .new {
//                Text("New")
//            }
//            if mode == .edit {
//                Text("Edit")
//            }
//
//            HStack {
//                Button("Ok") {
//                    handler(mode, item)
//                    presentationMode.wrappedValue.dismiss()
//                }
//                Spacer()
//                Button("Cancel") {
//                    handler(.none, nil)
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//            .padding()
//        }
//    }
// }
