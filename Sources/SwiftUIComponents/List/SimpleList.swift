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
    private let rowColor: Color!
    private let rowAlternateColor: Color!
    private let alternatesRows: Bool!

    var form: () -> Form

    public init(controller: ListController<Item, Row>, @ViewBuilder form: @escaping () -> Form) {
        self.controller = controller
        self.form = form
        #if os(iOS)
            UITableView.appearance().backgroundColor = .clear // <-- here
        #endif
        rowColor = controller.rowBackgroundColor

        switch controller.style {
        case let .plain(alternatesRows: alternatesRows, alternateBackgroundColor: alternateBackgroundColor):
            self.alternatesRows = alternatesRows
            rowAlternateColor = alternateBackgroundColor

        case let .inset(alternatesRows: alternatesRows, alternateBackgroundColor: alternateBackgroundColor):
            self.alternatesRows = alternatesRows
            rowAlternateColor = alternateBackgroundColor

        case let .grouped(alternatesRows: alternatesRows, alternateBackgroundColor: alternateBackgroundColor):
            self.alternatesRows = alternatesRows
            rowAlternateColor = alternateBackgroundColor

        case let .insetGrouped(alternatesRows: alternatesRows, alternateBackgroundColor: alternateBackgroundColor):
            self.alternatesRows = alternatesRows
            rowAlternateColor = alternateBackgroundColor

        case let .sidebar(alternatesRows: alternatesRows, alternateBackgroundColor: alternateBackgroundColor):
            self.alternatesRows = alternatesRows
            rowAlternateColor = alternateBackgroundColor
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
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
                    #if os(iOS)
                        .frame(width: 30, height: 30)
                    #endif
                    #if os(macOS)
                        .frame(width: 20, height: 20)
                    #endif
                    .foregroundColor(controller.addButtonColor)
                }
                #if os(macOS)
                    .buttonStyle(PlainButtonStyle())
                #endif
            }
            .padding([.leading, .trailing])
            .background(controller.backgroundColor)

            List {
                ForEach(0 ..< controller.items.count, id: \.self) { idx in
                    let item = controller.items[idx]
                    #if os(macOS)
                        VStack(spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                controller.makeRow(item)
                            }
                            .background(currentColor(idx: idx))
//                            .if(alternatesRows) { view in
//                                view
//                                    .background(idx % 2 == 0 ? rowColor : rowAlternateColor)
//                            }
//                            .if(!alternatesRows) { view in
//                                view
//                                    .background(rowColor)
//                            }
                            .onTapGesture {
                                controller.select(item: item)
                            }
                            .modifier(AttachActions(controller: controller, item: item, sheetManager: sheetManager))
                            if controller.showLineSeparator {
                                Divider()
                                    .if(controller.lineSeparatorColor != nil) { view in
                                        view
                                            .background(controller.lineSeparatorColor!)
                                    }
                            }
                        }
                    #endif
                    #if os(iOS)
                        HStack(alignment: .center, spacing: 0) {
                            controller.makeRow(item)
                        }
                        .background(currentColor(idx: idx))
//                        .if(alternatesRows) { view in
//                            view
//                                .background(idx % 2 == 0 ? rowColor : rowAlternateColor)
//                        }
//                        .if(!alternatesRows) { view in
//                            view
//                                .background(rowColor)
//                        }
                        .onTapGesture {
                            controller.select(item: item)
                        }
                        .if(!controller.showLineSeparator) { view in
                            view
                                .listRowSeparator(.hidden)
                        }
                        .if(controller.lineSeparatorColor != nil) { view in
                            view
                                .listRowSeparatorTint(controller.lineSeparatorColor!)
                        }
                        .modifier(AttachActions(controller: controller, item: item, sheetManager: sheetManager))
                    #endif
                }
                #if os(macOS)
                    .removingScrollViewBackground()
                #endif
                .listRowBackground(Color.clear)
            }
            .customStyle(type: controller.style)
            .background(controller.backgroundColor)
            .sheet(isPresented: $sheetManager.showSheet) {
                if sheetManager.whichSheet == .Form {
                    form()
                }
            }
        }
        .background(controller.backgroundColor)
    }

    func currentColor(idx: Int) -> Color {
        if !alternatesRows {
            return rowColor
        }
        return idx % 2 == 0 ? rowColor : rowAlternateColor
    }
}

fileprivate struct AttachActions<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ViewModifier {
    var controller: ListController<Item, Row>
    var item: Item
    var sheetManager: SheetMananger

    func body(content: Content) -> some View {
        content
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
                                                                                  style: .grouped(alternatesRows: true, alternateBackgroundColor: .white),
                                                                                  title: "Title",
                                                                                  addButtonColor: .red,
                                                                                  editButtonLabel: "Edit_",
                                                                                  deleteButtonLabel: "Delete_",
                                                                                  backgroundColor: .green,
                                                                                  rowBackgroundColor: .purple,
                                                                                  leadingActions: leadingActions,
                                                                                  trailingActions: trailingActions,
                                                                                  actionHandler: { actionKey in
                                                                                      print("Executing action \(actionKey)")
                                                                                  },
                                                                                  showLineSeparator: true,
                                                                                  lineSeparatorColor: .blue,
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
        VStack {
            HStack {
                Text("\(item.firstName)")
                Text("\(item.lastName)")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(item.selected ? Color.red : Color.clear)
        }
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
