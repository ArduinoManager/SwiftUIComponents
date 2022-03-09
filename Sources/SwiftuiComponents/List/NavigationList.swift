//
//  ListNavigationView.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/4/22.
//

import SwiftUI

public struct NavigationList<Item: Hashable & Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View, Form: View>: View {
    @ObservedObject var controller: ListController<Item, Row>
    @StateObject var sheetManager = SheetMananger()
    @State private var selection: String? = nil

    var form: () -> Form

    public init(controller: ObservedObject<ListController<Item, Row>>, @ViewBuilder form: @escaping () -> Form) {
        _controller = controller
        self.form = form
        UITableView.appearance().backgroundColor = .clear // <-- here
    }

    public var body: some View {
        NavigationView {
            VStack {
//                NavigationLink(destination: FormView1(mode: .new, item: nil) { mode, newItem in
//                    if mode == .new {
//                        viewModel.add(item: newItem!)
//                    }
//                }, tag: "newItem", selection: $selection) { EmptyView() }

                HStack {
                    Text("Title")
                        .font(.title)
                    Spacer()
                    Button("Add") {
                        selection = "newItem"
                    }
                }
                .padding([.leading, .trailing])

                List {
                    ForEach(controller.items, id: \.id) { item in

                        NavigationLink(destination: form,
                                       isActive: Binding<Bool>(get: { isTapped },
                                                               set: {
                                                                   isTapped = $0
                                                                   print("Tapped")
                                                                   controller.mode = .edit
                                                                   controller.editingItem = item
                                                               }),
                                       label: { controller.makeRow(item) })

//                        NavigationLink(destination: form(), tag: item, selection: $controller.editingItem) {
//                            controller.makeRow(item)
//                        }

//                        NavigationLink(destination: {
//                            form()
//
//
                        ////                            FormView1(mode: .edit, item: item) { mode, editedItem in
                        ////                                if mode == .edit {
                        ////                                    viewModel.update(oldItem: item, newItem: editedItem!)
                        ////                                }
                        ////                            }
//                        }, tag: item, selection: $controller.editingItem
//                        )
//                        {
//                            controller.makeRow(item)
//                                .navigationBarHidden(true)
//                                .onTapGesture {
//                                    controller.select(item: item)
//                                }
//                        }
                    }
                }
            }
            Text("\(controller.selectedItems.debugDescription)")
        }
        .navigationBarHidden(true)
    }
}

// Preview

struct NavigationListContainer: View {
    @ObservedObject private var controller: ListController<ListItem, RowView>

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

        controller = ListController<ListItem, RowView>(items: items,
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
                                                       makeRow: { item in
                                                           RowView(item: item)
                                                       })
    }

    var body: some View {
        NavigationList(controller: _controller) {
            MyForm(controller: _controller)
        }
    }
}

struct NavigationList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationListContainer()
    }
}

// Auxiliary Preview Items
