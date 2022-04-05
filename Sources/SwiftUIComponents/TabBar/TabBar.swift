//
//  SwiftUIView.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import SwiftUI

public struct TabBar: View {
    @StateObject var controller: TabBarController
    @State var selectedTab: TabItem

    #if os(iOS)
        public init(controller: TabBarController) {
            _controller = StateObject(wrappedValue: controller)
            _selectedTab = State(initialValue: controller.tabs[0])
            UITabBar.appearance().backgroundColor = UIColor(controller.backgroundColor)
        }

        public var body: some View {
            VStack(spacing: 0) {
                ForEach(controller.tabs, id: \.self) { tab in

                    if tab == selectedTab {
                        controller.viewProvider(controller,tab)
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
    #endif

    #if os(macOS)

        public init(controller: TabBarController) {
            _controller = StateObject(wrappedValue: controller)
            _selectedTab = State(initialValue: controller.tabs[0])
        }

        public var body: some View {
            TabView {
                ForEach(0 ..< controller.tabs.count, id: \.self) { idx in
                    let tab = controller.tabs[idx]

                    controller.viewProvider(controller, tab)
                        .tabItem {
                            Text(tab.title)
                        }
                }
            }
        }
    #endif
}

struct TabBarContainer: View {
    #if os(iOS)
        @ObservedObject private var controller = TabBarController(views: [
            TabItem(key: 0, title: "Tab 1", systemIcon: "list.dash"),
            TabItem(key: 1, title: "Tab 2", systemIcon: "square.and.pencil"),
            TabItem(key: 2, title: "Tab 3", systemIcon: "person.2.circle", iconColor: .yellow),
            TabItem(key: 3, title: "Tab 4", icon: "tabIcon"),
            TabItem(key: 4, title: "Tab 5", icon: "tabIcon", iconColor: .black),
        ],
        viewProvider: viewProvider,
        backgroundColor: Color(.gray),
        itemsColor: .green
        )
    #endif
    #if os(macOS)
        @ObservedObject private var controller = TabBarController(views: [
            TabItem(key: 0, title: "Tab 1", systemIcon: "list.dash"),
            TabItem(key: 1, title: "Tab 2", systemIcon: "square.and.pencil"),
            TabItem(key: 2, title: "Tab 3", systemIcon: "person.2.circle", iconColor: .yellow),
            TabItem(key: 3, title: "Tab 4", icon: "tabIcon"),
            TabItem(key: 4, title: "Tab 5", icon: "tabIcon", iconColor: .black),
        ],
        viewProvider: viewProvider
        )
    #endif
    var body: some View {
        TabBar(controller: controller)
    }
}

fileprivate func viewProvider(controller: TabBarController, item: TabItem) -> AnyView {
    switch item.key {
    case 0:
        return AnyView(Tab1().background(.red))
        
    case 1:
        return AnyView(Tab2())

    case 2:
        return AnyView(Tab3())

    case 3:
        return AnyView(Tab4())

    case 4:
        return AnyView(Tab5())
        
    default:
        return AnyView(EmptyView())
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

struct Tab4: View {
    var body: some View {
        Text("Tab 4")
    }
}

struct Tab5: View {
    var body: some View {
        Text("Tab 5")
    }
}
