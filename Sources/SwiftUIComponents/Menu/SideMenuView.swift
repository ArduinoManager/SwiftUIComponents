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
        #if os(iOS)
            let buttonHeight: CGFloat = 48.0
        #endif
        #if os(macOS)
            let buttonHeight: CGFloat = 30.0
        #endif

        public var body: some View {
            VStack {
                if controller.sideTitleView != nil {
                    HStack {
                        controller.sideTitleView
                        #if os(iOS)
                            .frame(maxWidth: getRect().width / 2, alignment: .leading)
                        #endif
                        Spacer()
                    }
                } else {
                    Spacer(minLength: 20)
                }

                // Print("Redraw with Height \(getRect().height)")
                ScrollView(.vertical, showsIndicators: false) {
                    // Tab Buttons
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(controller.menuItems, id: \.self) { item in

                            switch item {
                            case is TabMenuItem:
                                CustomTabButton(item: item)

                            case is HandlerMenuItem:
                                CustomActionButton(item: item)

                            case is TabMenuSpacer:
                                Spacer(minLength: item.height)

                            case is TabMenuDivider:
                                let i = item as! TabMenuDivider
                                Divider()
                                #if os(iOS)
                                    .background(i.color != nil ? i.color! : Color(uiColor: .label))
                                #endif
                                #if os(macOS)
                                    .background(i.color != nil ? i.color! : Color(NSColor.labelColor))
                                #endif
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .padding(.top, 10)
                #if os(iOS)
                    .frame(width: getRect().width / 2, alignment: .leading)
                #endif

                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(controller.backgroundColor)
            #if os(iOS)
                .onRotate { _ in
                    controller.objectWillChange.send() // Force redraw!
                }
            #endif
        }

        @ViewBuilder
        func CustomTabButton(item: MenuItem) -> some View {
            Button {
                withAnimation {
                    controller.currentTab = item.title
                }
            }
            label: {
                HStack {
                    makeImage(item: item)
                        .font(.title3)
                        .frame(width: controller.currentTab == item.title ? buttonHeight : nil, height: buttonHeight)
                        .foregroundColor(controller.currentTab == item.title ? controller.selectedItemBackgroundColor : controller.itemsColor)
                        .background(
                            ZStack {
                                if controller.currentTab == item.title {
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
                        if controller.currentTab == item.title {
                            controller.selectedItemBackgroundColor
                                .clipShape(Capsule())
                                .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                        }
                    }
                )
            }
            #if os(iOS)
                .offset(x: controller.currentTab == item.title ? 15 : 0)
            #endif
            #if os(macOS)
                .buttonStyle(PlainButtonStyle())
            #endif
        }

        @ViewBuilder
        func CustomActionButton(item: MenuItem) -> some View {
            Button {
                withAnimation {
                    item.handler!()
                }
            }
            label: {
                HStack {
                    makeImage(item: item)
                        .font(.title3)
                        .frame(width: controller.currentTab == item.title ? buttonHeight : nil, height: buttonHeight)
                        .foregroundColor(controller.currentTab == item.title ? controller.selectedItemBackgroundColor : controller.itemsColor)
                        .background(
                            ZStack {
                                if controller.currentTab == item.title {
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
                        if controller.currentTab == item.title {
                            controller.selectedItemBackgroundColor
                                .clipShape(Capsule())
                                .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                        }
                    }
                )
            }
            #if os(iOS)
                .offset(x: controller.currentTab == item.title ? 15 : 0)
            #endif
            #if os(macOS)
                .buttonStyle(PlainButtonStyle())
            #endif
        }

        @ViewBuilder
        func makeImage(item: MenuItem) -> some View {
            if item.icon != nil {
                item.icon!
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            } else {
                Image(systemName: item.systemIcon!)
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
                if controller.sideTitleView != nil {
                    HStack {
                        controller.sideTitleView!
                    }
                } else {
                    Spacer(minLength: 20)
                }

                List {
                    ForEach(controller.menuItems, id: \.self) { item in

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

                        case is HandlerMenuItem:
                            NavigationLink(destination: EmptyView()) {
                                Button {
                                    item.handler!()
                                } label: {
                                    HStack(alignment: .center) {
                                        makeImage(item: item)
                                            .foregroundColor(controller.itemsColor)
                                        Text(item.title)
                                            .foregroundColor(controller.itemsColor)
                                    }
                                }
                                .buttonStyle(.plain)
                            }

                        case is TabMenuSpacer:
                            Spacer(minLength: item.height)

                        case is TabMenuDivider:
                            let i = item as! TabMenuDivider
                            Divider()
                                .background(i.color != nil ? i.color! : Color(NSColor.labelColor))

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
                }
            }
            
            // .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
        }

        @ViewBuilder
        func makeImage(item: MenuItem) -> some View {
            if item.icon != nil {
                item.icon!
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } else {
                Image(systemName: item.systemIcon!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }
#endif

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
