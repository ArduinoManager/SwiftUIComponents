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
                        if let titleView = controller.titleViewProvider?(controller) {
                            titleView
                                .overlay(alignment: .leading) {
                                    OpenButton()
                                        .padding(.leading, 20)
                                }
                        }
                    }
                    // .padding([.horizontal], isLandscape() ? 40 : 20)
                    .padding(.bottom, 2)
                    .padding(.top, isLandscape() ? 10.0 : getSafeArea().top)
                }

                TabView(selection: $controller.currentTab) {
                    ForEach(controller.menuItems, id: \.self) { item in
                        if item is MenuView {
                            Print("\(item.title)")
                            controller.makeView(item: item as! MenuView)
                                // (item as! MenuView).makeView()
                                .tag(item.key)
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
                        if controller.titleViewProvider != nil {
                            controller.titleViewProvider?(controller)
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
            if controller.inspectorViewProvider == nil {
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
            if controller.titleViewProvider == nil {
                //
                // No Title View
                //
                controller.makeView(item: item as! MenuView)
                    // (item as! MenuView).makeView()
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
                        controller.titleViewProvider!(controller)
                    }
                    .background(controller.titleViewBackgroundColor)
                    controller.makeView(item: item as! MenuView)
                        // (item as! MenuView).makeView()
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
            if controller.titleViewProvider == nil {
                //
                // No Title View
                //

                // Inspector without Title View
                HSplitView {
                    // Main View
                    if let i = item as? MenuView {
                        controller.makeView(item: i)
                            // i.makeView()
                            .onAppear(perform: {
                                print("---- 2️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                                controller.currentTab = item.key

                            })
                            .layoutPriority(1)
                    }

                    // Inspector
                    if showInspector {
                        controller.inspectorViewProvider!(controller)
                            .frame(idealWidth: 500)
                    }
                }
                .if(controller.inspectorViewProvider != nil && controller.titleViewProvider == nil) { view in
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
                            // controller.titleView
                            controller.titleViewProvider?(controller)
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
                                controller.makeView(item: i)
                                    // i.makeView()
                                    .onAppear(perform: {
                                        print("---- 3️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                                        controller.currentTab = item.key
                                    })
                                    .layoutPriority(1)
                            }

                            if showInspector {
                                controller.inspectorViewProvider!(controller)
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
            MenuView(key: 0, title: "Home", systemIcon: "theatermasks.fill"),
            MenuAction(key: 100, title: "Print", systemIcon: "rectangle.portrait.and.arrow.right"),
            MenuView(key: 1, title: "Simple Table", systemIcon: "safari.fill"),
            MenuView(key: 2, title: "Devices", systemIcon: "applewatch"),
            MenuSpacer(height: 50),
            MenuView(key: 3, title: "Profile", systemIcon: "person.fill"),
            MenuView(key: 4, title: "Profile2", icon: "logo"),

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
                                                                   // titleView: AnyView(TitleView()),
                                                                   titleViewProvider: { _ in
                                                                       AnyView(TitleView())
                                                                   },
                                                                   titleViewBackgroundColor: .red,
                                                                   // titleViewBackgroundColor: Color(.sRGB, red: 0.9254902601242065, green: 0.9254902601242065, blue: 0.9254902601242065, opacity: 1.0),
                                                                   menuHandler: { _, item in
                                                                       print("Action \(item.title) [\(item.key)]")
                                                                   },
                                                                   viewProvider: { _, menuItem in

                                                                       if menuItem.key == 0 {
                                                                           return AnyView(TestView(text: "Home").background(.yellow))
                                                                       }

                                                                       if menuItem.key == 1 {
                                                                           return AnyView(TestView(text: "Discover").background(.blue))
                                                                       }

                                                                       if menuItem.key == 2 {
                                                                           return AnyView(TestView(text: "Devices").background(.gray))
                                                                       }

                                                                       if menuItem.key == 3 {
                                                                           return AnyView(TestView(text: "Profile").background(.green))
                                                                       }

                                                                       if menuItem.key == 4 {
                                                                           return AnyView(TestView(text: "Profile").background(.green))
                                                                       }
                                                                       return AnyView(EmptyView())
                                                                   }
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
                                   sideTitleViewProvider: { _ in
                                       AnyView(TitleView())
                                   },
                                   backgroundColor: Color(nsColor: .windowBackgroundColor),
                                   itemsColor: .red,
                                   titleViewProvider: { _ in
                                       AnyView(TitleView())
                                   },
                                   // titleView: AnyView(TitleView()),
                                   titleViewBackgroundColor: .cyan,
                                   inspectorViewProvider: { _ in
                                       AnyView(Inspector())
                                   },
                                   menuHandler: { _, _ in

                                   },
                                   viewProvider: { _, menuItem in

                                       if menuItem.key == 0 {
                                           return AnyView(TestView(text: "Home").background(.yellow))
                                       }

                                       if menuItem.key == 1 {
                                           return AnyView(TestView(text: "Discover").background(.blue))
                                       }

                                       if menuItem.key == 2 {
                                           return AnyView(TestView(text: "Devices").background(.gray))
                                       }

                                       if menuItem.key == 3 {
                                           return AnyView(TestView(text: "Profile").background(.green))
                                       }

                                       if menuItem.key == 4 {
                                           return AnyView(TestView(text: "Profile").background(.green))
                                       }
                                       return AnyView(EmptyView())
                                   }
            )

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
