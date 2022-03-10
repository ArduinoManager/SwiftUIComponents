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
            List {
                NavigationLink(destination: ContentView()) {
                    Label("Welcome", systemImage: "star")
                }
                
                Spacer()
                
                Text("DASHBOARD")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group{
                    NavigationLink(destination: ContentView()) {
                        Label("Home", systemImage: "house")
                    }
                    NavigationLink(destination: ContentView()) {
                        Label("Websites", systemImage: "globe")
                    }
                    NavigationLink(destination: ContentView()) {
                        Label("Domains", systemImage: "link")
                    }
                    NavigationLink(destination: ContentView()) {
                        Label("Templates", systemImage: "rectangle.stack")
                    }
                }
                
                Spacer()
                
                Text("PROFILE")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group {
                    NavigationLink(destination: ContentView()) {
                        Label("My Account", systemImage: "person")
                    }
                    NavigationLink(destination: ContentView()) {
                        Label("Notifications", systemImage: "bell")
                    }
                    NavigationLink(destination: ContentView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                Spacer()
                
                Divider()
                NavigationLink(destination: ContentView()) {
                    Label("Sign Out", systemImage: "arrow.backward")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Explore")
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            .padding([.leading], 0)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
            
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

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
