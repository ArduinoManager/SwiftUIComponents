//
//  ContainerView.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

public struct ContainerView: View {
    @ObservedObject var controller: MenuController
    @State private var orientation = UIDeviceOrientation.unknown

    public var body: some View {
        VStack(spacing: 0) {
            if controller.openButtonAtTop {
                HStack(spacing: 0) {
                    OpenButton()
                    Spacer()
                    if controller.titleView != nil {
                        controller.titleView
                    }
                }
                .padding([.horizontal], isLandscape() ? 40 : 20)
                .padding(.bottom)
                .padding(.top, isLandscape() ? 10.0 : getSafeArea().top)
            }

            TabView(selection: $controller.currentTab) {
                ForEach(controller.menuItems, id: \.self) { item in
                    item.makeView()
                        .tag(item.title)
                }
            }
            .onChange(of: controller.currentTab, perform: { _ in
                if controller.autoClose {
                    withAnimation(.spring()) {
                        controller.showMenu = false
                    }
                }
            })

            if !controller.openButtonAtTop {
                HStack(spacing: 0) {
                    OpenButton()
                    Spacer()
                    if controller.titleView != nil {
                        controller.titleView
                    }
                }
                .padding([.horizontal])
                .padding(.top)
                .padding(.bottom, getSafeArea().bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(CloseButton(), alignment: .topLeading)
        .background(controller.titleViewBackground)
    }

    @ViewBuilder
    func OpenButton() -> some View {
        Button {
            withAnimation(.spring()) {
                controller.showMenu.toggle()
            }
        } label: {
            Image(systemName: controller.openButtonIcon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .font(.title.bold())
                .foregroundColor(.black)
                .frame(width: controller.openMenuSize, height: controller.openMenuSize)
        }
        .opacity(controller.showMenu ? 0 : 1)
    }

    @ViewBuilder
    func CloseButton() -> some View {
        Button {
            withAnimation(.spring()) {
                controller.showMenu.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .font(.title.bold())
                .foregroundColor(.black)
        }
        .opacity(controller.showMenu ? 1 : 0)
        .padding()
        .padding(.top)
    }

    func isLandscape() -> Bool {
        return UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
    }
}

struct MainViewContainer: View {
    @ObservedObject private var controller = MenuController(menuItems:
        [
            TabMenuItem(title: "Home", icon: "theatermasks.fill", view: AnyView(TestView(text: "Home").background(.yellow))),
            HandlerMenuItem(title: "Print", icon: "rectangle.portrait.and.arrow.right") {
                print("Print")
            },
            TabMenuItem(title: "Discover", icon: "safari.fill", view: AnyView(TestView(text: "Discover").background(.blue))),
            TabMenuItem(title: "Devices", icon: "applewatch", view: AnyView(TestView(text: "Devices").background(.gray))),
            TabMenuSpacer(height: 50),
            TabMenuItem(title: "Profile", icon: "person.fill", view: AnyView(TestView(text: "Profile").background(.green))),

            TabMenuDivider(),
            HandlerMenuItem(title: "Login", icon: "rectangle.portrait.and.arrow.right") {
                print("Login")
            },

            HandlerMenuItem(title: "Logout", icon: "rectangle.portrait.and.arrow.right") {
                print("Logout")
            },
        ]
    )

    var body: some View {
        Menu(controller: _controller)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}

struct TestView: View {
    @State var text: String

    var body: some View {
        VStack {
            Spacer()
            Text(text)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
