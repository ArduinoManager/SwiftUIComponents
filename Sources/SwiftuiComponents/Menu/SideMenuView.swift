//
//  SideMenu.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

public struct SideMenuView: View {
    @ObservedObject var controller: MenuController
    @Namespace var animation

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
                                .background(i.color != nil ? i.color! : Color(uiColor: .label))

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
                controller.currentTab = item.title
            }
        }
        label: {
            HStack {
                makeImage(item: item)
                    .font(.title3)
                    .frame(width: controller.currentTab == item.title ? 48 : nil, height: 48)
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
        .offset(x: controller.currentTab == item.title ? 15 : 0)
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
                    .frame(width: controller.currentTab == item.title ? 48 : nil, height: 48)
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
        .offset(x: controller.currentTab == item.title ? 15 : 0)
    }
    
    
    @ViewBuilder
    func makeImage(item: MenuItem) -> some View {
        if item.icon != nil {
            Image(item.icon!)
        }
        else {
            Image(systemName: item.systemIcon!)
        }
    }
    
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
