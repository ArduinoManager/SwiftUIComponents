//
//  ListNavigationView.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/4/22.
//

import SwiftUI

public struct NavigationList<Item: Hashable & Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View, Form: View>: View {
    @ObservedObject private var controller: ListController<Item, Row>
    @State private var isTapped = false
    @State private var editingList = false
    private var form: (_ mode: FormMode) -> Form
    private let rowColor: GenericColor!
    private let rowAlternateColor: GenericColor!
    private let alternatesRows: Bool!

    public init(controller: ListController<Item, Row>, @ViewBuilder form: @escaping (_ mode: FormMode) -> Form) {
        self.controller = controller
        self.form = form
        #if os(iOS)
            UITableView.appearance().backgroundColor = .clear
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
        NavigationView {
            VStack {
                HStack {
                    if let header = controller.headerProvider() {
                        header
                    }
                    Spacer()
                    Button {
                        controller.editingItem = nil
                        controller.detailingItem = nil
                        controller.startNewItem = true
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
                        .padding(.trailing, 6)
                    #endif
                    #if os(iOS)
                        .padding(.trailing, 6)
                    #endif
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

                List {
                    ForEach(0 ..< controller.items.count, id: \.self) { idx in
                        let item = controller.items[idx]

                        #if os(iOS)
                            VStack(alignment: .leading, spacing: 0) {
                                NavigationLink(
                                    destination: form(.edit).navigationBarHidden(true),
                                    tag: item,
                                    selection: $controller.editingItem,
                                    label: {})
                                    .hidden()

                                NavigationLink(
                                    destination: controller.detailProvider() != nil ? controller.detailProvider().navigationBarHidden(true) : EmptyView(),
                                    tag: item,
                                    selection: $controller.detailingItem,
                                    label: {})
                                    .hidden()

                                HStack(alignment: .center, spacing: 0) {
                                    controller.makeRow(item)
                                        .modifier(AttachActions(controller: controller, item: item))
                                        .modifier(AttachSwipeActions(controller: controller, item: item))
                                        .background(currentColor(idx: idx).color)
                                        .onLongPressGesture {
                                            editingList.toggle()
                                        }
                                        .layoutPriority(1)

                                    Button {
                                        controller.detailingItem = item
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .foregroundColor(GenericColor.systemTint.color)
                                            .scaledToFit()
                                            .frame(width: iconSize + 1, height: iconSize + 1)
                                            .padding(2)
                                    }
                                    .buttonStyle(.plain)
                                    .background(currentColor(idx: idx).color)
                                }
                                if controller.showLineSeparator {
                                    Divider()
                                        .if(controller.lineSeparatorColor != nil) { view in
                                            view
                                                .background(controller.lineSeparatorColor!.color)
                                        }
                                }
                            }
                        #endif
                        #if os(macOS)
                            VStack(alignment: .leading, spacing: 0) {
                                NavigationLink(
                                    destination: controller.editingItem! = nil ? form(.edit) : AnyView(EmptyView()),
                                    tag: item,
                                    selection: $controller.editingItem,
                                    label: {})
                                    .hidden()

                                NavigationLink(
                                    destination: controller.detailProvider() != nil ? controller.detailProvider() : AnyView(EmptyView()),
                                    tag: item,
                                    selection: $controller.detailingItem,
                                    label: {})
                                    .hidden()

                                HStack(alignment: .center, spacing: 0) {
                                    controller.makeRow(item)
                                        .modifier(AttachActions(controller: controller, item: item))
                                        .modifier(AttachSwipeActions(controller: controller, item: item))
                                        .background(currentColor(idx: idx).color)
                                        .layoutPriority(1)
                                    Button {
                                        controller.editingItem = nil
                                        controller.detailingItem = item
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .foregroundColor(GenericColor.systemTint.color)
                                            .scaledToFit()
                                            .frame(width: iconSize + 1, height: iconSize + 1)
                                            .padding(2)
                                    }
                                    .buttonStyle(.plain)
                                    .background(currentColor(idx: idx).color)
                                }
                                if controller.showLineSeparator {
                                    Divider()
                                        .if(controller.lineSeparatorColor != nil) { view in
                                            view
                                                .background(controller.lineSeparatorColor!.color)
                                        }
                                }
                            }
                        #endif
                    }
                    .onMove(perform: move)
                    .listRowBackground(GenericColor.systemClear.color)
                }
                #if os(iOS)
                    .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive))
                #endif
                .customStyle(type: controller.style)

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
            .overlay(ZStack {
                NavigationLink(destination:
                    form(.new)
                    #if os(iOS)
                        .navigationBarHidden(true)
                    #endif
                    , tag: "newItem", selection: Binding<String?>(
                        get: {
                            controller.startNewItem ? "newItem" : ""
                        },
                        set: { _ in
                        }
                    )
                    , label: { EmptyView() }).hidden()
            })
            #if os(iOS)
                .navigationBarTitle("")
                .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
            .navigationViewStyle(.stack)
        #endif
    }

    private func move(from source: IndexSet, to destination: Int) {
        controller.items.move(fromOffsets: source, toOffset: destination)
    }

    private func currentColor(idx: Int) -> GenericColor {
        if !alternatesRows {
            return rowColor
        }
        return idx % 2 == 0 ? rowColor : rowAlternateColor
    }
}

fileprivate struct AttachActions<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ViewModifier {
    @ObservedObject var controller: ListController<Item, Row>
    var item: Item

    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if !controller.swipeActions {
                ForEach(0 ..< controller.leadingActions.count, id: \.self) { idx in
                    let action = controller.leadingActions[idx]
                    Button {
                        controller.selectedAction = SelectedAction(key: action.key, item: item)
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
            }

            //
            if !controller.swipeActions {
                ForEach(0 ..< controller.trailingActions.count, id: \.self) { idx in
                    let action = controller.trailingActions[idx]
                    Button {
                        controller.selectedAction = SelectedAction(key: action.key, item: item)
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
//                .onMove(perform: move)
            }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        controller.items.move(fromOffsets: source, toOffset: destination)
    }
}

fileprivate struct AttachSwipeActions<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ViewModifier {
    @ObservedObject var controller: ListController<Item, Row>
    var item: Item

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                ForEach(0 ..< controller.leadingActions.count, id: \.self) { idx in
                    let action = controller.leadingActions[idx]
                    Button(LocalizedStringKey(action.label)) {
                        controller.selectedAction = SelectedAction(key: action.key, item: item)
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
                }
                ForEach(Array(stride(from: controller.trailingActions.count - 1, to: -1, by: -1)), id: \.self) { idx in
                    let action = controller.trailingActions[idx]
                    Button(LocalizedStringKey(action.label)) {
                        controller.selectedAction = SelectedAction(key: action.key, item: item)
                    }
                    .tint(action.color.color)
                }
            }
    }
}

// Preview

class ThisNavigationController: ListController<ListItem, RowView> {
    override func headerProvider() -> AnyView? {
        return AnyView(TitleView())
    }

    override func footerProvider() -> AnyView? {
        return AnyView(TitleView())
    }

    override func detailProvider() -> AnyView? {
        // return AnyView(TitleView())
        return nil
    }
}

struct NavigationListContainer: View {
    @StateObject private var controller: ThisNavigationController

    init() {
        let items = [ListItem(firstName: "A", lastName: "A"),
                     ListItem(firstName: "B", lastName: "B"),
                     ListItem(firstName: "C", lastName: "C")]

        let leadingActions = [
            ListAction(key: "L1", label: "Action 1", systemIcon: "plus", color: GenericColor(color: .blue)),
            ListAction(key: "L2", label: "Action 2", systemIcon: "plus", color: GenericColor(color: .orange)),
        ]

        let trailingActions = [
            ListAction(key: "T1", label: "Action 1", systemIcon: "plus", color: GenericColor(color: .mint)),
            ListAction(key: "T2", label: "Action 2", icon: "logo", color: GenericColor(color: .mint)),
        ]

        _controller = StateObject(wrappedValue: ThisNavigationController(items: items,
                                                                         style: .plain(alternatesRows: true, alternateBackgroundColor: .systemGray),
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
        NavigationList<ListItem, RowView, MyForm1>(controller: controller) { mode in
            MyForm1(controller: controller, mode: mode)
        }
        #if os(iOS)
            .navigationBarHidden(true)
        #endif
    }
}

struct NavigationList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationListContainer()
                .previewInterfaceOrientation(.portrait)
        }
    }
}

// Auxiliary Preview Items

struct MyForm1: View {
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
