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
                        Print(".")
                        if item is MenuView {
                            (item as! MenuView).makeView()
                                .tag(item.title)
                        }
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
        @State private var showInspector = false

        public var body: some View {
            if controller.inspector == nil {
                //
                // No Inspector
                //
                viewNoInspector(controller: controller)
//                    .onAppear {
//                        print("---- 1️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
//                        controller.currentTab = item.key
//                    }
            } else {
                //
                // Inspector Inspector
                //
                viewWithInspector(controller: controller)
            }
        }

        @ViewBuilder
        func viewNoInspector(controller: MenuController) -> some View {
            if controller.titleView == nil {
                //
                // No Title View
                //
                (item as! MenuView).makeView()
                    .onAppear(perform: {
                        print("---- 2️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                        controller.currentTab = item.key
                    })
                    .layoutPriority(1)
            } else {
                //
                // Title View
                //
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        controller.titleView
                    }
                    .background(controller.titleViewBackgroundColor)
                    (item as! MenuView).makeView()
                        .onAppear(perform: {
                            print("---- 3️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                            controller.currentTab = item.key
                        })
                        .layoutPriority(1)
                }
            }
        }

        @ViewBuilder
        func viewWithInspector(controller: MenuController) -> some View {
            if controller.titleView == nil {
                //
                // No Title View
                //

                // Inspector without Title View
                HSplitView {
                    // Main View
                    if let i = item as? MenuView {
                        i.makeView()
                            .onAppear(perform: {
                                print("---- 2️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                                controller.currentTab = item.key

                            })
                            .layoutPriority(1)
                    }

                    // Inspector
                    if showInspector {
                        controller.inspector!
                            .frame(idealWidth: 500)
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
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 5)
                                    .padding(.trailing, 5)
                                }
                                Spacer()
                            }
                        )
                }
            } else {
                //
                // Title View
                //
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            controller.titleView
                            Spacer()
                            Button {
                                withAnimation {
                                    showInspector.toggle()
                                }
                            }
                            label: {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 10)
                        }
                        .background(controller.titleViewBackgroundColor)
                        HSplitView {
                            if let i = item as? MenuView {
                                i.makeView()
                                    .onAppear(perform: {
                                        print("---- 3️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                                        controller.currentTab = item.key
                                    })
                                    .layoutPriority(1)
                            }

                            if showInspector {
                                controller.inspector!
                                    .frame(idealWidth: 500)
                            }
                        }
                    }
                }
            }
        }
    }

#endif

struct MainViewContainer: View {
    @StateObject private var controller: MenuController

    init() {
        let menuItems = [
            MenuView(key: 0, title: "Home", systemIcon: "theatermasks.fill", view: AnyView(TestView(text: "Home").background(.yellow))),
            MenuAction(key: 100, title: "Print", systemIcon: "rectangle.portrait.and.arrow.right"),
            MenuView(key: 1, title: "Simple Table", systemIcon: "safari.fill", view: AnyView(TestView(text: "Discover").background(.blue))),
            MenuView(key: 2, title: "Devices", systemIcon: "applewatch", view: AnyView(TestView(text: "Devices").background(.gray))),
            MenuSpacer(height: 50),
            MenuView(key: 3, title: "Profile", systemIcon: "person.fill", view: AnyView(TestView(text: "Profile").background(.green))),
            MenuView(key: 4, title: "Profile2",
                     icon: "logo",
                     view: AnyView(TestView(text: "Profile").background(.green))),

            MenuDivider(color: .red),
            MenuAction(key: 101, title: "Login", systemIcon: "rectangle.portrait.and.arrow.right"),

            MenuAction(key: 102, title: "Logout", systemIcon: "pippo"),

            MenuDivider(color: .red),
            MenuAction(key: 103, title: "Kill!", icon: "logo"),
        ]

        #if os(iOS)
            _controller = StateObject(wrappedValue: MenuController(menuItems: menuItems,
                                                                   // sideTitleView: AnyView(SideTitleView()),
                                                                   backgroundColor: .blue,
                                                                   itemsColor: .red,
                                                                   menuHandler: { _, item in
                                                                       print("Action \(item.title) [\(item.key)]")
                                                                   }
//        titleView: AnyView(TitleView()),
//        titleViewBackgroundColor: .accentColor,
                )
            )
        #endif
        #if os(macOS)

            // No Title View - No Inspector

//            let x = MenuController(menuItems: menuItems,
//                                   sideTitleView: nil,
//                                   backgroundColor: Color(nsColor: .windowBackgroundColor),
//                                   itemsColor: .red,
//                                   titleView: nil,
//                                   titleViewBackgroundColor: Color(nsColor: .labelColor),
//                                   inspector: nil)

            // Title View - No Inspector

//            let x = MenuController(menuItems: menuItems,
//                                   sideTitleView: nil,
//                                   backgroundColor: Color(nsColor: .windowBackgroundColor),
//                                   itemsColor: .red,
//                                   titleView: AnyView(TitleView()),
//                                   titleViewBackgroundColor: Color(nsColor: .labelColor),
//                                   inspector: nil)

            // No Title View - Inspector

//        let x = MenuController(menuItems: menuItems,
//                               sideTitleView: nil,
//                               backgroundColor: Color(nsColor: .windowBackgroundColor),
//                               itemsColor: .red,
//                               titleView: nil,
//                               titleViewBackgroundColor: .cyan,
//                               inspector: AnyView(Inspector()))

            // Title View - Inspector

            let x = MenuController(menuItems: menuItems,
                                   sideTitleView: nil,
                                   backgroundColor: Color(nsColor: .windowBackgroundColor),
                                   itemsColor: .red,
                                   titleView: AnyView(TitleView()),
                                   titleViewBackgroundColor: .cyan,
                                   inspector: AnyView(Inspector()),
                                   menuHandler: { _, _ in

                                   })

//

            _controller = StateObject(wrappedValue: x)

        #endif
    }

    var body: some View {
        Menu(controller: controller)
    }

    func handler(controller: MenuController, item: MenuAction) {
    }
}

// Auxiliary Views

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
        HStack {
            Text("This is the Title View")
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(.cyan)
    }
}

struct Inspector: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Inspector")
            Spacer()
        }
        // .frame(minWidth: 100, idealWidth: 300)
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
