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
    @State var showInspector = true

    public init(controller: MenuController) {
        self.controller = controller
        #if os(iOS)
            UITabBar.appearance().isHidden = true
        #endif
    }

    public var body: some View {
        #if os(macOS)
            let x = Self._printChanges()
            NavigationView {
                // Left Panel
                SideMenuView(controller: controller)

                if controller.inspector != nil {
                    VStack(spacing: 0) {
                        if controller.titleView != nil {
                            HStack {
                                controller.titleView
                                Button {
                                    withAnimation {
                                        showInspector.toggle()
                                    }
                                }
                                label: {
                                    Image(systemName: "line.3.horizontal")
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 10)
                            }
                            .background(controller.titleViewBackgroundColor)
                        }
                        HSplitView {
                            ContainerView(controller: controller, item: controller.menuItems[0])
                                .layoutPriority(1)
                            // Inspector
                            if showInspector {
                                controller.inspector!
                                    .frame(idealWidth: 250)
                            }
                        }
                    }
                } else {
                    // Right Panel
                    VStack {
                        if controller.titleView != nil {
                            if showInspector {
                                controller.inspector!
                                    .frame(idealWidth: 250)
                            }
                        }
                        ContainerView(controller: controller, item: controller.menuItems[0])
                    }
                }
            }
            .if(controller.inspector != nil && controller.titleView == nil) { view in
                view
                    .overlay(
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation {
                                        showInspector.toggle()
                                    }
                                }
                                label: {
                                    Image(systemName: "line.3.horizontal")
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 5)
                                .padding(.trailing, 5)
                            }
                            Spacer()
                        }
                    )
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
