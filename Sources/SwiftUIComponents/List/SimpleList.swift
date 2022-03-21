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
    @ObservedObject private var controller: ListController<Item, Row>
    @StateObject private var sheetManager = SheetMananger()
    @State private var editingList = false
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
                    getSafeSystemImage(systemName: controller.addButtonIcon)
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
                            controller.makeRow(item)
                                .modifier(AttachActions(controller: controller, item: item, sheetManager: sheetManager))
                                .modifier(AttachSwipeActions(controller: controller, item: item, sheetManager: sheetManager))
                                .background(currentColor(idx: idx))
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
                        controller.makeRow(item)
                            .modifier(AttachActions(controller: controller, item: item, sheetManager: sheetManager))
                            .background(currentColor(idx: idx))
                            .modifier(AttachSwipeActions(controller: controller, item: item, sheetManager: sheetManager))
                            .if(!controller.showLineSeparator) { view in
                                view
                                    .listRowSeparator(.hidden)
                            }
                            .if(controller.lineSeparatorColor != nil) { view in
                                view
                                    .listRowSeparatorTint(controller.lineSeparatorColor!)
                            }
                            .onLongPressGesture {
                                editingList.toggle()
                            }
                    #endif
                }
                .onMove(perform: move)
                #if os(macOS)
                    .removingScrollViewBackground()
                #endif
                .listRowBackground(Color.clear)
            }
            #if os(iOS)
                .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive))
            #endif
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

    private func move(from source: IndexSet, to destination: Int) {
        controller.items.move(fromOffsets: source, toOffset: destination)
    }

    func currentColor(idx: Int) -> Color {
        if !alternatesRows {
            return rowColor
        }
        return idx % 2 == 0 ? rowColor : rowAlternateColor
    }
}

fileprivate struct AttachActions<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ViewModifier {
    @ObservedObject var controller: ListController<Item, Row>
    var item: Item
    var sheetManager: SheetMananger
    #if os(iOS)
        let iconSize: CGFloat = 25.0
    #endif
    #if os(macOS)
        let iconSize: CGFloat = 18.0
    #endif

    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if !controller.swipeActions {
                ForEach(0 ..< controller.leadingActions.count, id: \.self) { idx in
                    let action = controller.leadingActions[idx]
                    Button {
                        controller.actionHandler!(action.key)
                    } label: {
                        makeImage(action: action, iconSize: iconSize)
                    }
                    .frame(width: iconSize, height: iconSize)
                    .border(action.color, width: 1)
                    .padding(.top, 2)
                    .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                    .padding(.leading, idx == 0 ? 2 : 0)
                    #if os(iOS)
                        .tint(action.color)
                        .buttonStyle(BorderlessButtonStyle())
                    #endif
                    #if os(macOS)
                        .foregroundColor(action.color)
                        .buttonStyle(.plain)
                    #endif
                }
            }
            //
            content
                .onTapGesture {
                    controller.select(item: item)
                }
            //
            if !controller.swipeActions {
                Button {
                    controller.delete(item: item)
                } label: {
                    Image(systemName: "minus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .padding(2)
                }
                .frame(width: iconSize, height: iconSize)
                .border(.red, width: 1)
                .padding(.top, 2)
                .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                #if os(iOS)
                    .tint(.red)
                    .buttonStyle(BorderlessButtonStyle())
                #endif
                #if os(macOS)
                    .foregroundColor(.red)
                    .buttonStyle(.plain)
                #endif

                Button {
                    controller.editingItem = item
                    sheetManager.whichSheet = .Form
                    sheetManager.showSheet.toggle()
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .padding(2)
                }
                .frame(width: iconSize, height: iconSize)
                .border(Color.accentColor, width: 1)
                .padding(.top, 2)
                .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                .padding(.trailing, controller.trailingActions.count == 0 ? 2 : 0)
                #if os(iOS)
                    .tint(Color.accentColor)
                    .buttonStyle(BorderlessButtonStyle())
                #endif
                #if os(macOS)
                    .foregroundColor(Color.accentColor)
                    .buttonStyle(.plain)
                #endif

                ForEach(0 ..< controller.trailingActions.count, id: \.self) { idx in
                    let action = controller.trailingActions[idx]
                    Button {
                        controller.actionHandler!(action.key)
                    } label: {
                        makeImage(action: action, iconSize: iconSize)
                    }
                    .frame(width: iconSize, height: iconSize)
                    .border(action.color, width: 1)
                    .padding(.top, 1)
                    .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                    .padding(.trailing, idx == controller.trailingActions.count - 1 ? 2 : 0)
                    #if os(iOS)
                        .tint(action.color)
                        .buttonStyle(BorderlessButtonStyle())
                    #endif
                    #if os(macOS)
                        .foregroundColor(action.color)
                        .buttonStyle(.plain)
                    #endif
                }
            }
        }
    }
}

fileprivate struct AttachSwipeActions<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ViewModifier {
    @ObservedObject var controller: ListController<Item, Row>
    var item: Item
    var sheetManager: SheetMananger

    func body(content: Content) -> some View {
        content
            .if(controller.swipeActions) { view in
                view
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
                        ForEach(0 ..< controller.trailingActions.count, id: \.self) { idx in
                            let action = controller.trailingActions[idx]
                            Button(action.label) {
                                controller.actionHandler!(action.key)
                            }
                            .tint(action.color)
                        }
                    }
            }
    }
}

// Preview

struct SimpleListContainer: View {
    @StateObject private var controller: ListController<ListItem, RowView>

    init() {
        let items = [ListItem(firstName: "C", lastName: "C"),
                     ListItem(firstName: "A", lastName: "A"),
                     ListItem(firstName: "B", lastName: "B"),
        ]

//        controller = ListController<ListItem, RowView, FormView>(items: items,
//                                                                 title: "Title",
//                                                                 editButtonLabel: "Edit",
//                                                                 deleteButtonLabel: "Delete",
//                                                                 makeRow: { item in
//                                                                     RowView(item: item)
//                                                                 })

        let leadingActions = [
            ListAction(key: "L1", label: "Action 1", systemIcon: "plus", color: .blue),
            ListAction(key: "L2", label: "Action 2", systemIcon: "plus", color: .orange),
        ]

        let trailingActions = [
            ListAction(key: "T1", label: "Action 1", systemIcon: "plus", color: .mint),
            ListAction(key: "T2", label: "Action 2", icon: "logo", color: .red),
        ]

        _controller = StateObject(wrappedValue: ListController<ListItem, RowView>(items: items,
                                                                                  sort: sortList,
                                                                                  style: .grouped(alternatesRows: true, alternateBackgroundColor: .white),
                                                                                  title: "Title",
                                                                                  addButtonColor: .red,
                                                                                  editButtonLabel: "Edit_",
                                                                                  deleteButtonLabel: "Delete_",
                                                                                  backgroundColor: .green,
                                                                                  rowBackgroundColor: .purple,
                                                                                  swipeActions: false,
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

func sortList(list: inout [ListItem]) {
    list.sort {
        $0.lastName < $1.lastName
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
