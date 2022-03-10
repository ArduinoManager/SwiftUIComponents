//
//  MainView.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

// https://www.youtube.com/watch?v=qjeATKZkOIU

public struct Menu: View {
    @ObservedObject private var controller: MenuController

    public init(controller: MenuController) {
        self.controller = controller
        UITabBar.appearance().isHidden = true
    }

    public var body: some View {
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

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
