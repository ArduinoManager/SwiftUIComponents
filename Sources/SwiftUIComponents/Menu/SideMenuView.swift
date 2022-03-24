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
        let buttonHeight: CGFloat = 48.0

        public var body: some View {
            VStack {
                if controller.sideTitleView != nil {
                    HStack {
                        controller.sideTitleView
                            .frame(maxWidth: getRect().width / 2, alignment: .leading)
                        Spacer()
                    }
                } else {
                    Spacer(minLength: 20)
                        .background(controller.titleViewBackgroundColor)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    // Tab Buttons
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(controller.menuItems, id: \.self) { item in

                            switch item {
                            case is TabMenuItem:
                                CustomTabButton(item: item)

                            case is TabMenuHandler:
                                CustomActionButton(item: item as! TabMenuHandler)

                            case is TabMenuSpacer:
                                let thisItem = item as! TabMenuSpacer
                                Spacer(minLength: thisItem.spacerHeight)

                            case is TabMenuDivider:
                                let i = item as! TabMenuDivider
                                Divider()
                                    .background(i.color)

                            default:
                                EmptyView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .padding(.top, 10)
                .frame(width: getRect().width / 2, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(controller.backgroundColor)
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
                        .foregroundColor(controller.currentTab == item.key ? controller.selectedItemBackgroundColor : controller.itemsColor)
                        .background(
                            ZStack {
                                if controller.currentTab == item.key {
                                    Color.white
                                        .clipShape(Circle())
                                        .matchedGeometryEffect(id: "TABCIRCLE", in: animation)
                                }
                            }
                        )
                        .padding([.leading, .trailing], 1)

                    Text(item.title)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(controller.itemsColor)
                }

                .padding(.trailing, 18)
                .background(
                    ZStack {
                        if controller.currentTab == item.key {
                            controller.selectedItemBackgroundColor
                                .clipShape(Capsule())
                                .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                        }
                    }
                )
            }
            #if os(iOS)
                .offset(x: controller.currentTab == item.key ? 15 : 0)
            #endif
            #if os(macOS)
                .buttonStyle(PlainButtonStyle())
            #endif
        }

        @ViewBuilder
        func CustomActionButton(item: TabMenuHandler) -> some View {
            Button {
                withAnimation {
                    item.handler(controller)
                }
            }
            label: {
                HStack {
                    makeImage(item: item)
                        .font(.title3)
                        .frame(width: controller.currentTab == item.key ? buttonHeight : nil, height: buttonHeight)
                        .foregroundColor(controller.currentTab == item.key ? controller.selectedItemBackgroundColor : controller.itemsColor)
                        .background(
                            ZStack {
                                if controller.currentTab == item.key {
                                    Color.white
                                        .clipShape(Circle())
                                        .matchedGeometryEffect(id: "TABCIRCLE", in: animation)
                                }
                            }
                        )
                        .padding([.leading, .trailing], 1)

                    Text(item.title)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(controller.itemsColor)
                }

                .padding(.trailing, 18)
                .background(
                    ZStack {
                        if controller.currentTab == item.key {
                            controller.selectedItemBackgroundColor
                                .clipShape(Capsule())
                                .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                        }
                    }
                )
            }
            #if os(iOS)
                .offset(x: controller.currentTab == item.key ? 15 : 0)
            #endif
            #if os(macOS)
                .buttonStyle(PlainButtonStyle())
            #endif
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
                    NavigationLink(destination: controller.menuItems[0].view, tag: "A", selection: $controller.boostrap, label: { EmptyView().scaleEffect(0) })
                        .frame(width: 0, height: 0)
                        .hidden()
                }

                if controller.sideTitleView != nil {
                    HStack {
                        controller.sideTitleView!
                    }
                } else {
                    HStack(spacing: 0) {
                        Spacer()
                    }
                    .frame(minHeight: 20, idealHeight: 20, maxHeight: 20)
                    .background(controller.backgroundColor)
                }

                // Just a bit of space
                HStack(spacing: 0) {
                    Spacer()
                }
                .frame(minHeight: 5, idealHeight: 5, maxHeight: 5)
                .background(controller.backgroundColor)

                List {
                    ForEach(controller.menuItems, id: \.key) { item in

                        switch item {
                        case is TabMenuItem:
                            NavigationLink(destination: ContainerView(controller: controller, item: item)) {
                                HStack(alignment: .center) {
                                    makeImage(item: item)
                                        .foregroundColor(controller.itemsColor)
                                    Text(item.title)
                                        .foregroundColor(controller.itemsColor)
                                }
                            }

                        case is TabMenuHandler:
                            let thisItem = item as! TabMenuHandler

                            Button {
                                thisItem.handler(controller)
                            } label: {
                                HStack(alignment: .center) {
                                    makeImage(item: item)
                                        .foregroundColor(controller.itemsColor)
                                    Text(item.title)
                                        .foregroundColor(controller.itemsColor)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        case is TabMenuSpacer:
                            let thisItem = item as! TabMenuSpacer
                            Spacer(minLength: thisItem.spacerHeight)

                        case is TabMenuDivider:
                            let i = item as! TabMenuDivider
                            Divider()
                                .background(i.color)

                        default:
                            EmptyView()
                        }
                    }
                }
                .background(controller.backgroundColor)
                .listStyle(SidebarListStyle())
                // .navigationTitle("Explore")
                //
                .padding([.leading], 0)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar, label: {
                            Image(systemName: "sidebar.left")
                        })
                    }
                    ToolbarItem(placement: .navigation) {
                       Text("Cazzo")
                    }
                }
            }
            // .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
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

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
