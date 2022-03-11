//
//  ContentView.swift
//  Shared
//
//  Created by Fabrizio Boco on 3/3/22.
//

import SwiftUI

class SheetMananger: ObservableObject {
    enum Sheet {
        case Form
    }

    @Published var showSheet = false
    @Published var whichSheet: Sheet? = nil
}

public struct SimpleList<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View, Form: View>: View {
    @ObservedObject var controller: ListController<Item, Row>
    @StateObject var sheetManager = SheetMananger()

    var form: () -> Form

    public init(controller: ListController<Item, Row>, @ViewBuilder form: @escaping () -> Form) {
        self.controller = controller
        self.form = form
#if os(iOS)
        UITableView.appearance().backgroundColor = .clear // <-- here
        #endif
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
                    controller.editingItem = nil
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
                        .if(!controller.showLineSeparator) { view in
                            view
#if os(iOS)
                                .listRowSeparator(.hidden)
                            #endif
                        }
                        .if(controller.lineSeparatorColor != nil) { view in
                            view
#if os(iOS)
                                .listRowSeparatorTint(controller.lineSeparatorColor!)
                            #endif
                        }
                        .onTapGesture {
                            controller.select(item: item)
                        }
                        .swipeActions(edge: .leading) {
                            ForEach(0 ..< controller.leadingActions.count, id: \.self) { idx in
                                let action = controller.leadingActions[idx]
                                Button(action.label) {
                                    controller.actionHandler!(action.key)
                                }
                                .tint(action.color)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(controller.deleteButtonLabel) {
                                controller.delete(item: item)
                            }
                            .tint(.red)
                            Button(controller.editButtonLabel) {
                                controller.editingItem = item
                                sheetManager.whichSheet = .Form
                                sheetManager.showSheet.toggle()
                            }
                            ForEach(Array(stride(from: controller.trailingActions.count - 1, to: -1, by: -1)), id: \.self) { idx in
                                let action = controller.trailingActions[idx]
                                Button(action.label) {
                                    controller.actionHandler!(action.key)
                                }
                                .tint(action.color)
                            }
                        }
                }
                .listRowBackground(controller.rowBackgroundColor)
            }
            .customStyle(type: controller.style)
            .background(controller.backgroundColor)
            .sheet(isPresented: $sheetManager.showSheet) {
                if sheetManager.whichSheet == .Form {
                    form()
                }
            }
        }
    }
}

// Preview

struct SimpleListContainer: View {
    @StateObject private var controller: ListController<ListItem, RowView>

    init() {
        let items = [ListItem(firstName: "A", lastName: "A"),
                     ListItem(firstName: "B", lastName: "B"),
                     ListItem(firstName: "C", lastName: "C")]

//        controller = ListController<ListItem, RowView, FormView>(items: items,
//                                                                 title: "Title",
//                                                                 editButtonLabel: "Edit",
//                                                                 deleteButtonLabel: "Delete",
//                                                                 makeRow: { item in
//                                                                     RowView(item: item)
//                                                                 })

        let leadingActions = [
            ListAction(key: "L1", label: "Action 1", color: .blue),
            ListAction(key: "L2", label: "Action 2", color: .orange),
        ]

        let trailingActions = [
            ListAction(key: "T1", label: "Action 1", color: .mint),
            ListAction(key: "T2", label: "Action 2", color: .green),
        ]

        _controller = StateObject(wrappedValue: ListController<ListItem, RowView>(items: items,
                                                                                  style: .plain,
                                                                       title: "Title",
                                                                       addButtonColor: .green,
                                                                       editButtonLabel: "Edit_",
                                                                       deleteButtonLabel: "Delete_",
                                                                       backgroundColor: .green,
                                                                       rowBackgroundColor: .yellow,
                                                                       leadingActions: leadingActions,
                                                                       trailingActions: trailingActions,
                                                                       actionHandler: { actionKey in
                                                                           print("Executing action \(actionKey)")
                                                                       },
                                                                       showLineSeparator: true,
                                                                       lineSeparatorColor: .brown,
                                                                       makeRow: { item in
                                                                           RowView(item: item)
                                                                       }))
    }

    var body: some View {
        SimpleList<ListItem, RowView, MyForm>(controller: controller) {
            MyForm(controller: controller)
        }
    }
}

struct SimpleList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleListContainer()
                .previewInterfaceOrientation(.portraitUpsideDown)
            SimpleListContainer()
                .previewDevice(.init(stringLiteral: "iPad Pro (12.9-inch) (3rd generation)"))
        }
    }
}

// Auxiliary Preview Items

public class ListItem: ObservableObject, Hashable, Identifiable, Equatable, CustomDebugStringConvertible, ListItemInitializable, ListItemSelectable, ListItemCopyable {
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(item.selected ? Color.red : Color.clear)
    }
}

struct MyForm: View {
    @ObservedObject var controller: ListController<ListItem, RowView>
    @Environment(\.presentationMode) var presentationMode

    init(controller: ListController<ListItem, RowView>) {
        self.controller = controller
        
        // Required for NavigationList
        if controller.formItem == nil {
            controller.formItem = ListItem()
        }
    }

    var body: some View {
        VStack {
            Text("MyView")
            Spacer()
            Form {
                TextField("", text: $controller.formItem.firstName)
                TextField("", text: $controller.formItem.lastName)
                Text("\(controller.formItem.firstName.count)")
            }

            HStack {
                Button("Ok") {
                    controller.completeFormAction()
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
