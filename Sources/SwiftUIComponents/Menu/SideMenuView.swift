//
//  SideMenu.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

#if os(iOS)
    public struct SideMenuView: View {
        @ObservedObject var controller: MenuController
        @Namespace var animation
        // TODO: Move in the controller for configuration?
        let buttonHeight: CGFloat = 36.0
        let rightShiftWhenSelected: CGFloat = 5.0

        public var body: some View {
            VStack(alignment: .leading, spacing:0) {
                if let titleView = controller.sideTitleViewProvider() {
                    HStack {
                        titleView
                            .frame(maxWidth: getRect().width / 2, alignment: .leading)

                            .padding(0)
                            .background(controller.titleViewBackgroundColor.color) // Extra background layer to reset the shadow and stop it applying to every sub-view
                            .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                            .background(controller.backgroundColor.color)
                            .shadow(
                                color: Color.black.opacity(0.25),
                                radius: 3,
                                x: 0,
                                y: 0.5
                            )
                            .zIndex(99)
                        
                    }
                    .padding(0)
                } else {
                    Spacer(minLength: 15)
                        .background(controller.titleViewBackgroundColor.color)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    // Tab Buttons
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(controller.menuItems, id: \.self) { item in

                            switch item {
                            case is MenuView:
                                CustomTabButton(item: item)

                            case is MenuAction:
                                CustomActionButton(item: item as! MenuAction)

                            case is MenuSpacer:
                                let thisItem = item as! MenuSpacer
                                Spacer(minLength: thisItem.spacerHeight)

                            case is MenuDivider:
                                let i = item as! MenuDivider
                                Divider()
                                    .background(i.color.color)

                            default:
                                EmptyView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .padding(.leading, 10)
                .padding(.top, 10)
                .frame(width: getRect().width, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(controller.backgroundColor.color)
            .onRotate { _ in
                controller.objectWillChange.send() // Force redraw!
            }
        }

        @ViewBuilder
        func CustomTabButton(item: MenuItem) -> some View {
            Button {
                withAnimation {
                    controller.currentTab = item.key
                }
            }
            label: {
                HStack {
                    makeImage(item: item)
                        .font(.title3)
                        .frame(width: controller.currentTab == item.key ? buttonHeight : nil, height: buttonHeight)
                        .foregroundColor(controller.currentTab == item.key ? controller.backgroundColor.color : controller.itemsColor.color)
                        .background(
                            ZStack {
                                if controller.currentTab == item.key {
                                    controller.itemsColor.color
                                        .clipShape(Circle())
                                        .matchedGeometryEffect(id: "TABCIRCLE", in: animation)
                                }
                            }
                        )
                        .padding([.leading, .trailing], 0)

                    Text(LocalizedStringKey(item.title))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(controller.itemsColor.color)
                }

                .padding(.trailing, 18)
                .background(
                    ZStack {
                        if controller.currentTab == item.key {
                            controller.selectedItemBackgroundColor.color
                                .clipShape(Capsule())
                                .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                        }
                    }
                )
            }
            #if os(iOS)
                .offset(x: controller.currentTab == item.key ? rightShiftWhenSelected : 0)
            #endif
        }

        @ViewBuilder
        func CustomActionButton(item: MenuAction) -> some View {
            Button {
                withAnimation {
                    controller.lastAction = item
                }
            }
            label: {
                HStack {
                    makeImage(item: item)
                        .font(.title3)
                        .frame(width: controller.currentTab == item.key ? buttonHeight : nil, height: buttonHeight)
                        .foregroundColor(controller.currentTab == item.key ? controller.selectedItemBackgroundColor.color : controller.itemsColor.color)
                        .background(
                            ZStack {
                                if controller.currentTab == item.key {
                                    GenericColor.systemWhite.color
                                        .clipShape(Circle())
                                        .matchedGeometryEffect(id: "TABCIRCLE", in: animation)
                                }
                            }
                        )
                        .padding([.leading, .trailing], 1)

                    Text(LocalizedStringKey(item.title))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(controller.itemsColor.color)
                }

                .padding(.trailing, 18)
                .background(
                    ZStack {
                        if controller.currentTab == item.key {
                            controller.selectedItemBackgroundColor.color
                                .clipShape(Capsule())
                                .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                        }
                    }
                )
            }
        }

        @ViewBuilder
        func makeImage(item: MenuItem) -> some View {
            if item.icon != nil {
                getSafeImage(name: item.icon!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            } else {
                if let icon = item.systemIcon {
                    getSafeSystemImage(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
        }
    }
#endif

#if os(macOS)
    public struct SideMenuView: View {
        @ObservedObject var controller: MenuController
        @Namespace var animation
        let buttonHeight: CGFloat = 30.0

        public var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if controller.menuItems.count >= 1 {
                    NavigationLink(destination: ContainerView(controller: controller, item: controller.menuItems[0]), tag: "A", selection: $controller.boostrap, label: { EmptyView().scaleEffect(0) })
                        .frame(width: 0, height: 0)
                        .hidden()
                }

                if let titleView = controller.sideTitleViewProvider() {
                    HStack(spacing: 0) {
                        titleView
                    }
                    .padding(0)
                    .background(controller.titleViewBackgroundColor.color) // Extra background layer to reset the shadow and stop it applying to every sub-view
                    .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                    .background(controller.backgroundColor.color)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 3,
                        x: 0,
                        y: 0.5
                    )
                    .zIndex(99)

                } else {
                    HStack(spacing: 0) {
                        Spacer()
                    }
                    .frame(minHeight: 20, idealHeight: 20, maxHeight: 20)
                    .background(controller.backgroundColor.color)
                }

                // Just a bit of space
                HStack(spacing: 0) {
                    Spacer()
                }
                .frame(minHeight: 5, idealHeight: 5, maxHeight: 5)
                .background(controller.backgroundColor.color)

                List {
                    ForEach(controller.menuItems, id: \.key) { item in
                        switch item {
                        case is MenuView:
                            NavigationLink(destination: ContainerView(controller: controller, item: item)) {
                                HStack(alignment: .center) {
                                    makeImage(item: item)
                                        .foregroundColor(controller.itemsColor.color)
                                    Text(LocalizedStringKey(item.title))
                                        .foregroundColor(controller.itemsColor.color)
                                }
                            }

                        case is MenuAction:
                            let thisItem = item as! MenuAction

                            Button {
                                controller.lastAction = thisItem
                            } label: {
                                HStack(alignment: .center) {
                                    makeImage(item: item)
                                        .foregroundColor(controller.itemsColor.color)
                                    Text(LocalizedStringKey(item.title))
                                        .foregroundColor(controller.itemsColor.color)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        case is MenuSpacer:
                            let thisItem = item as! MenuSpacer
                            Spacer(minLength: thisItem.spacerHeight)

                        case is MenuDivider:
                            let i = item as! MenuDivider
                            Divider()
                                .background(i.color.color)

                        default:
                            EmptyView()
                        }
                    }
                }
                .background(controller.backgroundColor.color)
                .listStyle(SidebarListStyle())
                .padding([.leading], 0)
                .layoutPriority(1)
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
        }

        @ViewBuilder
        func makeImage(item: MenuItem) -> some View {
            if item.icon != nil {
                getSafeImage(name: item.icon!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } else {
                if let icon = item.systemIcon {
                    getSafeSystemImage(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
            }
        }
    }
#endif

// struct SideMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        MainViewContainer()
//    }
// }

struct SideMenuContainer: View {
    @State var controller = MyMenuController(menuItems:
        [
            MenuView(key: 0, title: "Home xxxxxx", systemIcon: "theatermasks.fill"),
            MenuAction(key: 100, title: "Print", systemIcon: "rectangle.portrait.and.arrow.right"),
            MenuView(key: 1, title: "Simple Table", systemIcon: "safari.fill"),
            MenuView(key: 2, title: "Devices", systemIcon: "applewatch"),
            MenuSpacer(height: 50),
            MenuView(key: 3, title: "Profile", systemIcon: "person.fill"),
            MenuView(key: 4, title: "Profile2", icon: "logo"),

            MenuDivider(color: GenericColor(systemColor: .systemRed)),
            MenuAction(key: 101, title: "Login", systemIcon: "rectangle.portrait.and.arrow.right"),

            MenuAction(key: 102, title: "Logout", systemIcon: "pippo"),

            MenuDivider(color: GenericColor(systemColor: .systemRed)),
            MenuAction(key: 103, title: "Kill!", icon: "logo"),
        ],
        backgroundColor: .systemBackground,
        itemsColor: .systemLabel,
        titleViewBackgroundColor: .systemBackground
    )

    var body: some View {
        SideMenuView(controller: controller)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            SideMenuContainer()
                .preferredColorScheme($0)
        }
    }
}
