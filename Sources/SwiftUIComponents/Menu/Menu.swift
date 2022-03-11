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
        #if os(iOS)
            UITabBar.appearance().isHidden = true
        #endif
    }

    public var body: some View {
        #if os(macOS)
        
        NavigationView {
            SideMenuView(controller: controller)
                .frame(width: 190)
            
            ContentView()
        }
    
        #endif
        #if os(iOS)
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
        #endif
    }
}

struct ContentView: View {
    var body: some View {
        Text("ContentView !!!!")
    }
}


// Toggle Sidebar Function
func toggleSidebar() {
    #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    #endif
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
