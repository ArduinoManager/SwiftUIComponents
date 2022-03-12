//
//  ListNavigationView.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/4/22.
//

import SwiftUI

public struct NavigationList<Item: Hashable & Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View, Form: View>: View {
    @ObservedObject var controller: ListController<Item, Row>
    @State private var isTapped = false
    private var form: () -> Form
    private let rowColor: Color!
    private let rowAlternateColor: Color!
    private let alternatesRows: Bool!

    public init(controller: ListController<Item, Row>, @ViewBuilder form: @escaping () -> Form) {
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
                    if let title = controller.title {
                        Text(title)
                            .font(.title)
                    }
                    Spacer()
                    Button {
                        controller.editingItem = nil
                        controller.startNewItem = "newItem"
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

                List {
                    ForEach(0 ..< controller.items.count, id: \.self) { idx in
                        let item = controller.items[idx]

                        #if os(iOS)
                            NavigationLink(destination:
                                form()
                                    .navigationBarHidden(true)
                                ,
                                isActive: Binding<Bool>(get: { isTapped },
                                                        set: {
                                                            isTapped = $0
                                                            controller.editingItem = item
                                                        }),
                                label: {
                                    HStack(alignment: .center, spacing: 0) {
                                        controller.makeRow(item)
                                    }
                                    .if(alternatesRows) { view in
                                        view
                                            .background(currentColor(idx: idx))
                                    }
                                    .if(!alternatesRows) { view in
                                        view
                                            .background(rowColor)
                                    }
                                    .onTapGesture {
                                        controller.select(item: item)
                                    }
                                }
                            )
                            .modifier(AttachActions(controller: controller, item: item))
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
                        #endif
                        #if os(macOS)
                            NavigationLink(
                                destination: form(),
                                tag: item,
                                selection:

                                Binding<Item?>(get: { controller.selectedItem },
                                               set: {
                                                   controller.selectedItem = $0
                                                   controller.editingItem = item
                                               })

                                ,
                                label: {
                                    HStack(alignment: .center, spacing: 0) {
                                        controller.makeRow(item)
                                    }
                                    .if(alternatesRows) { view in
                                        view
                                            .background(idx % 2 == 0 ? rowColor : rowAlternateColor)
                                    }
                                    .if(!alternatesRows) { view in
                                        view
                                            .background(rowColor)
                                    }
                                })
                        
                                .modifier(AttachActions(controller: controller, item: item))
                        
                            if controller.showLineSeparator {
                                Divider()
                                    .if(controller.lineSeparatorColor != nil) { view in
                                        view
                                            .background(controller.lineSeparatorColor!)
                                    }
                            }
                        #endif
                    }
                    .listRowBackground(Color.clear)
                }
                .customStyle(type: controller.style)
            }
            .background(controller.backgroundColor)
            .overlay(ZStack {
                NavigationLink(destination:
                    form()
                    #if os(iOS)
                        .navigationBarHidden(true)
                    #endif
                    , tag: "newItem", selection: $controller.startNewItem, label: { EmptyView() }).hidden()
            })
            #if os(iOS)
                .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
            .navigationViewStyle(.stack)
        #endif
    }

    func currentColor(idx: Int) -> Color {
        return idx % 2 == 0 ? rowColor : rowAlternateColor
    }
}

fileprivate struct AttachActions<Item: Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View>: ViewModifier {
    var controller: ListController<Item, Row>
    var item: Item

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

struct NavigationListContainer: View {
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
                                                                                  style: .grouped(alternatesRows: true, alternateBackgroundColor: .gray),
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
                                                                                  lineSeparatorColor: Color.blue,
                                                                                  makeRow: { item in
                                                                                      RowView(item: item)
                                                                                  }))
    }

    var body: some View {
        NavigationList<ListItem, RowView, MyForm1>(controller: controller) {
            MyForm1(controller: controller)
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
    @Environment(\.presentationMode) var presentationMode

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
