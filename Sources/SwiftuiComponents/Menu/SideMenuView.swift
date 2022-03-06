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
            HStack(spacing: 15) {
                if !controller.sideViewImage.isEmpty {
                    Image(controller.sideViewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }

                if !controller.sideViewTitle.isEmpty {
                    Text(controller.sideViewTitle)
                        .font(.title2.bold())
                        .foregroundColor(Color(uiColor: .label))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            //Print("Redraw with Height \(getRect().height)")
            ScrollView(.vertical, showsIndicators: false) {
                // Tab Buttons
                VStack(alignment: .leading, spacing: 25) {
                    ForEach(controller.menuItems, id: \.self) { item in

                        switch item {
                        case is TabMenuItem:
                            CustomTabButton(icon: item.icon, title: item.title)

                        case is HandlerMenuItem:
                            CustomActionButton(item: item)

                        case is TabMenuSpacer:
                            Spacer(minLength: item.height)
                                                        
                        case is TabMenuDivider:
                            Divider()
                            
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
        .background(controller.menuBackgroundColor)
        .onRotate { newOrientation in
            controller.objectWillChange.send() // Force redraw!
        }
    }

    @ViewBuilder
    func CustomTabButton(icon: String, title: String) -> some View {
        Button {
            withAnimation {
                controller.currentTab = title
            }
        }
        label: {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: controller.currentTab == title ? 48 : nil, height: 48)
                    .foregroundColor(controller.currentTab == title ? controller.selectedItemBackgroundColor : controller.itemsColor)
                    .background(
                        ZStack {
                            if controller.currentTab == title {
                                Color.white
                                    .clipShape(Circle())
                                    .matchedGeometryEffect(id: "TABCIRCLE", in: animation)
                            }
                        }
                    )
                    .padding([.leading, .trailing], 1)

                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(controller.itemsColor)
            }

            .padding(.trailing, 18)
            .background(
                ZStack {
                    if controller.currentTab == title {
                        controller.selectedItemBackgroundColor
                            .clipShape(Capsule())
                            .matchedGeometryEffect(id: "TABCAPSULE", in: animation)
                    }
                }
            )
        }
        .offset(x: controller.currentTab == title ? 15 : 0)
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
                Image(systemName: item.icon)
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
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
