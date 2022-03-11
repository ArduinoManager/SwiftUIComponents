//
//  ListNavigationView.swift
//  SuperList
//
//  Created by Fabrizio Boco on 3/4/22.
//

import SwiftUI

public struct NavigationList<Item: Hashable & Identifiable & Equatable & ListItemInitializable & ListItemSelectable & ListItemCopyable, Row: View, Form: View>: View {
    @ObservedObject var controller: ListController<Item, Row>
    @State private var selection: String? = nil
    @State private var isTapped = false
    private var form: () -> Form

    public init(controller: ListController<Item, Row>, @ViewBuilder form: @escaping () -> Form) {
        self.controller = controller
        self.form = form
        #if os(iOS)
            UITableView.appearance().backgroundColor = .clear
        #endif
    }

    public var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination:
                    form()
                    #if os(iOS)
                        .navigationBarHidden(true)
                    #endif
                    ,
                    tag: "newItem", selection: $selection) { EmptyView() }

                HStack {
                    if let title = controller.title {
                        Text(title)
                            .font(.title)
                    }
                    Spacer()
                    Button {
                        controller.editingItem = nil
                        selection = "newItem"
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
                        NavigationLink(destination:
                            form()
                            #if os(iOS)
                                .navigationBarHidden(true)
                            #endif
                            ,
                            isActive: Binding<Bool>(get: { isTapped },
                                                    set: {
                                                        isTapped = $0
                                                        controller.editingItem = item
                                                    }),
                            label: {
                                controller.makeRow(item)
                                    .onTapGesture {
                                        controller.select(item: item)
                                    }
                            }
                        )
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
                            ForEach(Array(stride(from: controller.trailingActions.count - 1, to: -1, by: -1)), id: \.self) { idx in
                                let action = controller.trailingActions[idx]
                                Button(action.label) {
                                    controller.actionHandler!(action.key)
                                }
                                .tint(action.color)
                            }
                        }
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
                    }
                    .listRowBackground(controller.rowBackgroundColor)
                }
                .customStyle(type: controller.style)
                .background(controller.backgroundColor)
            }
            #if os(iOS)
                .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
            .navigationViewStyle(.stack)
        #endif
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
                                                                                  style: .inset,
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
                .previewInterfaceOrientation(.portraitUpsideDown)
            NavigationListContainer()
                .previewDevice(.init(stringLiteral: "iPad Pro (12.9-inch) (3rd generation)"))
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
