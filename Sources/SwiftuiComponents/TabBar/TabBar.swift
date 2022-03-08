//
//  SwiftUIView.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import SwiftUI

public struct TabBar: View {
    @ObservedObject var controller: TabBarController
    @State var selectedTab: TabItem

    public init(controller: ObservedObject<TabBarController>) {
        _controller = controller
        _selectedTab = State(initialValue: controller.wrappedValue.tabs[0])
        UITabBar.appearance().backgroundColor = UIColor(controller.wrappedValue.backgroundColor)
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(controller.tabs, id: \.self) { tab in

                if tab == selectedTab {
                    tab.makeTab()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            HStack {
                ForEach(0 ..< controller.tabs.count, id: \.self) { idx in
                    let tab = controller.tabs[idx]
                    Button(action:
                        { selectedTab = tab }) {
                        VStack {
                            if let systemIcon = tab.systemIcon {
                                Image(systemName: systemIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.bottom, 2)
                            } else {
                                Image(tab.icon!, bundle: .module)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.bottom, 2)
                            }
                            Text(tab.title).font(.caption)
                        }
                        .foregroundColor(tab.iconColor == nil ? controller.itemsColor : tab.iconColor)
                    }.opacity(tab == selectedTab ? 0.5 : 1.0)

                    if idx < controller.tabs.count - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.top, 6)
            .padding(.horizontal, getRect().width / CGFloat(4 * controller.tabs.count))
            .frame(height: 48.0)
            .background(controller.backgroundColor)
        }
    }
}

struct TabBarContainer: View {
    @ObservedObject private var controller = TabBarController(views: [
        TabItem(title: "Tab 1", systemIcon: "list.dash", tab: AnyView(Tab1().background(.red))),
        TabItem(title: "Tab 2", systemIcon: "square.and.pencil", tab: AnyView(Tab2())),
        TabItem(title: "Tab 3", systemIcon: "person.2.circle", iconColor: .yellow, tab: AnyView(Tab3())),
        TabItem(title: "Tab 4", icon: "tabIcon", tab: AnyView(Tab3())),
        TabItem(title: "Tab 5", icon: "tabIcon", iconColor: .black, tab: AnyView(Tab3())),
    ],
    backgroundColor: Color(uiColor: .systemGroupedBackground),
    itemsColor: .green
    )

    var body: some View {
        TabBar(controller: _controller)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBarContainer()
    }
}

// Auxiliary Preview Views

struct Tab1: View {
    var body: some View {
        VStack {
            Text("Tab 1")
                .padding()
            Button("Button") {
            }
            .padding()
            Image(systemName: "square.and.pencil")
                .foregroundStyle(.green, .green)
                .padding()
        }
    }
}

struct Tab2: View {
    var body: some View {
        Text("Tab 2")
    }
}

struct Tab3: View {
    var body: some View {
        Text("Tab 3")
    }
}
