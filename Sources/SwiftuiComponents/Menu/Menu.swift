//
//  MainView.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

// https://www.youtube.com/watch?v=qjeATKZkOIU

struct Menu: View {
    @ObservedObject private var controller: MenuController

    init(controller: ObservedObject<MenuController>) {
        _controller = controller
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            // Side Menu
            SideMenuView(controller: controller)

            // Main Tab View
            ContainerView(controller: controller)
                .cornerRadius(controller.showMenu ? 25 : 0)
                .rotation3DEffect(.init(degrees: controller.showMenu ? -15 : 0), axis: (x: 0, y: 1, z: 0), anchor: .trailing)
                .offset(x: controller.showMenu ? getRect().width / 2 : 0)
                .ignoresSafeArea()
        }
    }
}

//struct MainViewContainer: View {
//    @ObservedObject private var controller = MenuController(menuItems:
//        [
//            TabMenuItem(title: "Home", icon: "theatermasks.fill", view: AnyView(HomeView(text: "Home"))),
//            HandlerMenuItem(title: "Print", icon: "rectangle.portrait.and.arrow.right") {
//                print("Print")
//            },
//            TabMenuItem(title: "Discover", icon: "safari.fill", view: AnyView(DiscoverView(text: "Discover"))),
//            TabMenuItem(title: "Devices", icon: "applewatch", view: AnyView(DevicesView(text: "Devices"))),
//            TabMenuItem(title: "Profile", icon: "person.fill", view: AnyView(ProfileView(text: "Profile"))),
//            //            MenuItem(title: "Profile", icon: "person.fill"),
//            //            MenuItem(title: "Settings", icon: "gearshape.fill"),
//            //            MenuItem(title: "About", icon: "info.circle.fill"),
//            //            MenuItem(title: "Help", icon: "questionmark.circle.fill"),
//
//            HandlerMenuItem(title: "Login", icon: "rectangle.portrait.and.arrow.right") {
//                print("Login")
//            },
//            
//            HandlerMenuItem(title: "Logout", icon: "rectangle.portrait.and.arrow.right") {
//                print("Logout")
//            }
//        ]
//    )
//
//    var body: some View {
//        Menu(controller: _controller)
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainViewContainer()
//    }
//}
