//
//  SwiftUIView.swift
//
//
//  Created by Fabrizio Boco on 3/7/22.
//

import SwiftUI

public struct TabBar: View {
    @ObservedObject var controller: TabBarController

    public init(controller: ObservedObject<TabBarController>) {
        _controller = controller
        UITabBar.appearance().backgroundColor = UIColor(controller.wrappedValue.backgroundColor)
    }

    public var body: some View {
        TabView {
            ForEach(controller.tabs, id: \.self) { tab in
                tab.makeTab()
                    .tabItem {
                        if let systemIcon = tab.systemIcon {
                            Label(tab.title, systemImage: systemIcon)
                        } else {
                            Label(tab.title, image: tab.icon!)
                        }
                    }
            }
        }
        .accentColor(controller.itemsColor)
    }
}

struct TabBarContainer: View {
    @ObservedObject private var controller = TabBarController(views: [
        TabItem(title: "Tab 1", systemIcon: "list.dash", tab: AnyView(Tab1())),
        TabItem(title: "Tab 2", systemIcon: "square.and.pencil", tab: AnyView(Tab2())),
        TabItem(title: "Tab 3", icon: "tabIcon", tab: AnyView(Tab3())),
    ],
    backgroundColor: .gray,
    itemsColor: .red
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
        Text("Tab 1")
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
