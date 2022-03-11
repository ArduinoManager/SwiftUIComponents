//
//  ContainerView.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

#if os(iOS)
    public struct ContainerView: View {
        @ObservedObject var controller: MenuController
        @State private var orientation = UIDeviceOrientation.unknown

        public var body: some View {
            Print(Self._printChanges())
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
            .background(controller.titleViewBackgroundColor)
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
                    .foregroundColor(controller.openButtonColor)
                    .frame(width: controller.openButtonSize, height: controller.openButtonSize)
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
                    .foregroundColor(controller.openButtonColor)
            }
            .opacity(controller.showMenu ? 1 : 0)
            .padding()
            .padding(.top)
        }

        func isLandscape() -> Bool {
            #if os(iOS)
                return UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
            #endif
            #if os(macOS)
                return true
            #endif
        }
    }
#endif

#if os(macOS)

    public struct ContainerView: View {
        @ObservedObject var controller: MenuController
        var item: MenuItem
        
        public var body: some View {
            VStack(spacing: 0) {
                //let _ = Self._printChanges()
                if controller.titleView != nil {
                    controller.titleView
                }
                item.makeView()
            }
        }
    }

#endif

struct MainViewContainer: View {
    @StateObject private var controller = MenuController(menuItems:
        [
            TabMenuItem(title: "Home", systemIcon: "theatermasks.fill", view: AnyView(TestView(text: "Home").background(.yellow))),
            HandlerMenuItem(title: "Print", systemIcon: "rectangle.portrait.and.arrow.right") {
                print("Print")
            },
            TabMenuItem(title: "Discover", systemIcon: "safari.fill", view: AnyView(TestView(text: "Discover").background(.blue))),
            TabMenuItem(title: "Devices", systemIcon: "applewatch", view: AnyView(TestView(text: "Devices").background(.gray))),
            TabMenuSpacer(height: 50),
            TabMenuItem(title: "Profile", systemIcon: "person.fill", view: AnyView(TestView(text: "Profile").background(.green))),
            TabMenuItem(title: "Profile2",
                        icon: Image("logo", bundle: .module),
                        view: AnyView(TestView(text: "Profile").background(.green))),

            TabMenuDivider(color: .red),
            HandlerMenuItem(title: "Login", systemIcon: "rectangle.portrait.and.arrow.right") {
                print("Login")
            },

            HandlerMenuItem(title: "Logout", systemIcon: "rectangle.portrait.and.arrow.right") {
                print("Logout")
            },

            TabMenuDivider(color: .red),
            HandlerMenuItem(title: "Kill!", icon: Image("logo", bundle: .module)) {
                print("Login")
            },
        ],
        sideTitleView: AnyView(SideTitleView()
        ),
        backgroundColor: .blue,
        itemsColor: .red,
        titleView: AnyView(TitleView())
    )

    var body: some View {
        Menu(controller: controller)
    }
}

struct SideTitleView: View {
    var body: some View {
        HStack(alignment: .center) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .padding(.vertical, 5)
                .padding(.leading, 10)
            Spacer()
            Text("Fuck !")
                .font(.title2.bold())
                .foregroundColor(.red)
                .padding(.trailing, 10)
        }
        .background(.green)
    }
}

struct TitleView: View {
    var body: some View {
        HStack{
            Text("This is the Title View")
        }
        .frame(maxWidth:.infinity, maxHeight: 40)
        .background(.cyan)
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainViewContainer()
        }
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
