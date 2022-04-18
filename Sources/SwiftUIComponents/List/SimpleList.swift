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
    // @State private var uuid: UUID
    private let rowColor: GenericColor!
    private let rowAlternateColor: GenericColor!
    private let alternatesRows: Bool!
    private var form: (_ mode: FormMode) -> Form

    public init(controller: ListController<Item, Row>, @ViewBuilder form: @escaping (_ mode: FormMode) -> Form) {
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

        // _uuid = State(initialValue: UUID())
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let header = controller.headerProvider() {
                HStack {
                    header
                        .overlay(alignment: .topTrailing) {
                            Button {
                                controller.editingItem = nil
                                sheetManager.whichSheet = .Form
                                sheetManager.showSheet.toggle()
                            } label: {
                                getSafeSystemImage(systemName: controller.addButtonIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(3)
                                    .foregroundColor(controller.addButtonColor.color)
                                    .frame(width: iconSize + 1, height: iconSize + 1)
                                    .border(controller.addButtonColor.color, width: 1)
                            }
                            #if os(macOS)
                                .buttonStyle(PlainButtonStyle())
                            #endif
                            .padding(.trailing, 6)
                                .padding(.top, 5)
                        }
                }
                .padding(0)
                .background(controller.backgroundColor.color)
                .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                .background(GenericColor.systemLabel.color)
                .shadow(
                    color: GenericColor.systemLabel.color.opacity(0.5),
                    radius: 3,
                    x: 0,
                    y: 0.5
                )
                .zIndex(99)
            } else {
                HStack(spacing: 0) {
                    Spacer()
                    Button {
                        controller.editingItem = nil
                        sheetManager.whichSheet = .Form
                        sheetManager.showSheet.toggle()
                    } label: {
                        getSafeSystemImage(systemName: controller.addButtonIcon)
                            .aspectRatio(contentMode: .fit)
                            .padding(3)
                            .foregroundColor(controller.addButtonColor.color)
                            .frame(width: iconSize + 1, height: iconSize + 1)
                            .border(controller.addButtonColor.color, width: 1)
                    }
                    #if os(macOS)
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, controller.isPlain ? -5 : 2)
                    #endif
                    #if os(iOS)
                        .padding(.trailing, 6)
                    #endif
                    .padding(.top, 10)
                }
            }

            List {
                ForEach(0 ..< controller.items.count, id: \.self) { idx in
                    let item = controller.items[idx]
                    #if os(macOS)
                        VStack(spacing: 0) {
                            controller.makeRow(item)
                                .modifier(AttachActions(controller: controller, item: item, sheetManager: sheetManager))
                                .modifier(AttachSwipeActions(controller: controller, item: item, sheetManager: sheetManager))
                                .background(currentColor(idx: idx).color)
                            if controller.showLineSeparator {
                                Divider()
                                    .if(controller.lineSeparatorColor != nil) { view in
                                        view
                                            .background(controller.lineSeparatorColor!.color)
                                    }
                            }
                        }
                    #endif
                    #if os(iOS)
                        controller.makeRow(item)
                            .modifier(AttachActions(controller: controller, item: item, sheetManager: sheetManager))
                            .background(currentColor(idx: idx).color)
                            .modifier(AttachSwipeActions(controller: controller, item: item, sheetManager: sheetManager))
                            .if(!controller.showLineSeparator) { view in
                                view
                                    .listRowSeparator(.hidden)
                            }
                            .if(controller.lineSeparatorColor != nil) { view in
                                view
                                    .listRowSeparatorTint(controller.lineSeparatorColor!.color)
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
                .listRowBackground(GenericColor.systemClear.color)
            }
            #if os(iOS)
                .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive))
            #endif
            .customStyle(type: controller.style)
                .background(controller.backgroundColor.color)
                .sheet(isPresented: $sheetManager.showSheet) {
                    if sheetManager.whichSheet == .Form {
                        form(controller.editingItem == nil ? .new : .edit)
                    }
                }
            Spacer()
            if let footer = controller.footerProvider() {
                HStack(spacing: 0) {
                    footer
                }
                .padding(0)
                .background(controller.backgroundColor.color)
                .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                .background(GenericColor.systemLabel.color)
                .shadow(
                    color: GenericColor.systemLabel.color.opacity(0.5),
                    radius: 3,
                    x: 0,
                    y: 0.5
                )
                .zIndex(99)
            }
        }
        .background(controller.backgroundColor.color)
    }

    private func move(from source: IndexSet, to destination: Int) {
        controller.items.move(fromOffsets: source, toOffset: destination)
    }

    func currentColor(idx: Int) -> GenericColor {
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

    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if !controller.swipeActions {
                ForEach(0 ..< controller.leadingActions.count, id: \.self) { idx in
                    let action = controller.leadingActions[idx]
                    Button {
                        controller.currentActionKey = action.key
                    } label: {
                        makeImage(action: action, iconSize: iconSize, color: action.color)
                    }
                    .padding(.top, 2)
                    .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                    .padding(.leading, idx == 0 ? 2 : 0)
                    #if os(iOS)
                        .buttonStyle(BorderlessButtonStyle())
                    #endif
                    #if os(macOS)
                        .foregroundColor(action.color.color)
                        .buttonStyle(.plain)
                    #endif
                }
            }
            //
            content
                .contentShape(Rectangle()) // This makes all the row selectable!
                .onTapGesture {
                    controller.select(item: item)
                }
            //
            if !controller.swipeActions {
                Button {
                    controller.delete(item: item)
                } label: {
                    getSafeSystemImage(systemName: "trash.fill")
                        .aspectRatio(contentMode: .fit)
                        .padding(3)
                        .foregroundColor(.red)
                        .frame(width: iconSize + 1, height: iconSize + 1)
                        .border(.red, width: 1)
                }
                .padding(.top, 2)
                .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                #if os(iOS)
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
                    getSafeSystemImage(systemName: "pencil")
                        .aspectRatio(contentMode: .fit)
                        .padding(3)
                        .foregroundColor(.accentColor)
                        .frame(width: iconSize + 1, height: iconSize + 1)
                        .border(Color.accentColor, width: 1)
                }
                .padding(.top, 2)
                .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                .padding(.trailing, controller.trailingActions.count == 0 ? 2 : 0)
                #if os(iOS)
                    .buttonStyle(BorderlessButtonStyle())
                #endif
                #if os(macOS)
                    .foregroundColor(Color.accentColor)
                    .buttonStyle(.plain)
                #endif

                ForEach(0 ..< controller.trailingActions.count, id: \.self) { idx in
                    let action = controller.trailingActions[idx]
                    Button {
                        controller.currentActionKey = action.key
                    } label: {
                        makeImage(action: action, iconSize: iconSize, color: action.color)
                    }
                    .padding(.top, 1)
                    .padding(.bottom, controller.showLineSeparator ? 2 : 0)
                    .padding(.trailing, idx == controller.trailingActions.count - 1 ? 2 : 0)
                    #if os(iOS)
                        .buttonStyle(BorderlessButtonStyle())
                    #endif
                    #if os(macOS)
                        .foregroundColor(action.color.color)
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
                            Button(LocalizedStringKey(action.label)) {
                                controller.currentActionKey = action.key
                            }
                            .tint(action.color.color)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(LocalizedStringKey(controller.deleteButtonLabel)) {
                            controller.delete(item: item)
                        }
                        .tint(.red)
                        Button(LocalizedStringKey(controller.editButtonLabel)) {
                            controller.editingItem = item
                            sheetManager.whichSheet = .Form
                            sheetManager.showSheet.toggle()
                        }
                        ForEach(0 ..< controller.trailingActions.count, id: \.self) { idx in
                            let action = controller.trailingActions[idx]
                            Button(LocalizedStringKey(action.label)) {
                                controller.currentActionKey = action.key
                            }
                            .tint(action.color.color)
                        }
                    }
            }
    }
}

// Preview

class ThisListController: ListController<ListItem, RowView> {
    override func headerProvider() -> AnyView? {
        return AnyView(TitleView())
    }

    override func footerProvider() -> AnyView? {
        return AnyView(TitleView())
    }
}

struct SimpleListContainer: View {
    @StateObject private var controller: ThisListController

    init() {
        let items = [ListItem(firstName: "C", lastName: "C"),
                     ListItem(firstName: "A", lastName: "A"),
                     ListItem(firstName: "B", lastName: "B"),
        ]

        let leadingActions = [
            ListAction(key: "L1", label: "Action 1", systemIcon: "pencil", color: .systemBlue),
            ListAction(key: "L2", label: "Action 2", systemIcon: "plus", color: GenericColor(systemColor: .systemOrange)),
        ]

        let trailingActions = [
            ListAction(key: "T1", label: "Action 1", systemIcon: "pencil", color: GenericColor(systemColor: .systemMint)),
            ListAction(key: "T2", label: "Action 2", icon: "logo", color: .systemRed),
        ]

        _controller = StateObject(wrappedValue: ThisListController(items: items,
                                                                   
                                                                   style: .grouped(alternatesRows: false, alternateBackgroundColor: GenericColor(color: .white)),
                                                                   addButtonIcon: "plus",
                                                                   addButtonColor: .systemRed,
                                                                   editButtonLabel: "Edit_",
                                                                   deleteButtonLabel: "Delete_",
                                                                   backgroundColor: .systemGreen,
                                                                   rowBackgroundColor: GenericColor(systemColor: .systemPurple),
                                                                   swipeActions: false,
                                                                   leadingActions: leadingActions,
                                                                   trailingActions: trailingActions,
                                                                   showLineSeparator: true,
                                                                   lineSeparatorColor: .systemBlue,
                                                                   makeRow: { item in
                                                                       RowView(item: item)
                                                                   }))
    }

    var body: some View {
        SimpleList<ListItem, RowView, MyForm>(controller: controller) { mode in
            MyForm(controller: controller, mode: mode)
        }
    }
}

struct SimpleList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleListContainer()
                .previewInterfaceOrientation(.portrait)
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
            .background(item.selected ? GenericColor.systemRed.color : GenericColor.systemClear.color)
        }
    }
}

struct MyForm: View {
    @ObservedObject var controller: ListController<ListItem, RowView>
    var mode: FormMode
    @Environment(\.presentationMode) var presentationMode

    init(controller: ListController<ListItem, RowView>, mode: FormMode) {
        self.controller = controller
        self.mode = mode
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
