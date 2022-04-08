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

    @State private var selection = 0

    // Where the tab bar will be located within the view
    public enum TabBarPosition: Codable {
        case top
        case bottom
    }

    public init(controller: TabBarController) {
        _controller = StateObject(wrappedValue: controller)
        _selectedTab = State(initialValue: controller.tabs[0])
    }

    #if os(iOS)
        public var body: some View {
            VStack(spacing: 0) {
                if controller.tabBarPosition == .top {
                    tabBar
                }
                controller.viewProvider?(controller, controller.tabs[selection])
                    .padding(0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if controller.tabBarPosition == .bottom {
                    tabBar
                }
            }
            .padding(0)
        }

        public var tabBar: some View {
            VStack {
                HStack {
                    ForEach(0 ..< controller.tabs.count, id: \.self) { index in
                        let tab = controller.tabs[index]

                        Spacer()

                        VStack {
                            if let icon = tab.systemIcon {
                                Image(systemName: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(self.selection == index ? controller.selectionColor.color : tab.color.color)

                            } else {
                                getSafeImage(name: tab.icon!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                            }
                            Text(tab.title)
                                .foregroundColor(self.selection == index ? controller.selectionColor.color : tab.color.color)
                        }
                        .frame(height: 48)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        // .border(.white, width: 2)
                        .onTapGesture {
                            self.selection = index
                        }

                        Spacer()
                    }
                }
                .padding(0)
                .background(controller.backgroundColor.color) // Extra background layer to reset the shadow and stop it applying to every sub-view
                .shadow(color: GenericColor.clear.color, radius: 0, x: 0, y: 0)
                .background(controller.backgroundColor.color)
//        .shadow(
//            color: Color.black.opacity(0.25),
//            radius: 3,
//            x: 0,
//            y: controller.tabBarPosition == .top ? 1 : -1
//        )
//        .zIndex(99) // Raised so that shadow is visible above view backgrounds
            }
            .background(controller.backgroundColor.color)
        }
    #endif

    #if os(macOS)
        public var body: some View {
            VStack(spacing: 0) {
                if controller.tabBarPosition == .top {
                    tabBar
                }
                controller.viewProvider?(controller, controller.tabs[selection])
                    .padding(0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if controller.tabBarPosition == .bottom {
                    tabBar
                }
            }
            .padding(0)
        }

        public var tabBar: some View {
            HStack {
                Spacer()
                ForEach(0 ..< controller.tabs.count, id: \.self) { index in
                    let tab = controller.tabs[index]

                    HStack {
                        if let icon = tab.systemIcon {
                            getSafeSystemImage(systemName: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                        } else {
                            getSafeImage(name: tab.icon!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                        }
                        Text(tab.title)
                    }
                    .frame(height: 20)
                    .padding(5)
                    .padding(.horizontal, 10)
                    .foregroundColor(self.selection == index ? controller.selectionColor.color : tab.color.color)
                    .onTapGesture {
                        self.selection = index
                    }
                }
                Spacer()
            }
            .padding(0)
            .background(controller.backgroundColor.color) // Extra background layer to reset the shadow and stop it applying to every sub-view
            .shadow(color: GenericColor.clear.color, radius: 0, x: 0, y: 0)
            .background(controller.backgroundColor.color)
            .shadow(
                color: Color.black.opacity(0.25),
                radius: 3,
                x: 0,
                y: controller.tabBarPosition == .top ? 1 : -1
            )
            .zIndex(99) // Raised so that shadow is visible above view backgrounds
        }
    #endif
}

struct TabBarContainer: View {
    @ObservedObject private var controller = TabBarController(tabs: [
        TabItem(key: 0, title: "Tab 1", systemIcon: "list.dash", color: .systemBlue),
        TabItem(key: 1, title: "Tab 2", systemIcon: "square.and.pencil", color: .systemGreen),
        TabItem(key: 2, title: "Tab 3", systemIcon: "person.2.circle", color: .systemYellow),
        TabItem(key: 3, title: "Tab 4", icon: "tabIcon"),
        TabItem(key: 4, title: "Tab 5", icon: "tabIcon", color: .systemBlack),
    ],
    tabBarPosition: .bottom,
    viewProvider: viewProvider,
    backgroundColor: GenericColor.systemBackground
    )

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
