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
                if controller.headerAtTop {
                    HStack(spacing: 0) {
                        if let titleView = controller.headerProvider() {
                            titleView
                                .overlay(alignment: .bottomLeading) {
                                    OpenButton()
                                        .padding(.leading, 20)
                                }
                        }
                    }
                    .padding(0)
                    .background(controller.headerBackgroundColor.color)
                    .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                    .background(GenericColor.systemLabel.color)
                    .shadow(
                        color: GenericColor.systemLabel.color.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 0.5
                    )
                    .zIndex(99)
                }

                viewToShow()
                    .onChange(of: controller.currentTab, perform: { _ in
                        if controller.autoClose {
                            withAnimation(.spring()) {
                                controller.showMenu = false
                            }
                        }
                    })

                if !controller.headerAtTop {
                    HStack(spacing: 0) {
                        if let titleView = controller.headerProvider() {
                            titleView
                                .overlay(alignment: .leading) {
                                    OpenButton()
                                        .padding(.leading, 20)
                                }
                        }
                    }
                    .padding(0)
                    .background(controller.headerBackgroundColor.color)
                    .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                    .background(GenericColor.systemLabel.color)
                    .shadow(
                        color: GenericColor.systemLabel.color.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 0.5
                    )
                    .zIndex(99)
                }
            }
            // .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemBackground)
            .overlay(CloseButton(), alignment: .topLeading)
            .overlay(alignment: .bottomLeading) {
                if controller.headerProvider() == nil && !controller.headerAtTop {
                    OpenButton()
                        .padding(.leading)
                        .padding(.bottom)
                }
            }
            .overlay(alignment: .topLeading) {
                if controller.headerProvider() == nil && controller.headerAtTop {
                    OpenButton()
                        .padding(.leading)
                        .padding(.top)
                }
            }
            .onRotate { orientation in
                self.orientation = orientation
            }
        }

        @ViewBuilder
        func viewToShow() -> some View {
            let item = controller.menuItems.first(where: { $0.key == controller.currentTab })
            controller.viewProvider(item: item as! MenuView)
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
                    .aspectRatio(contentMode: .fit)
                    .font(.title.bold())
                    .foregroundColor(controller.openButtonColor.color)
                    .frame(width: controller.openButtonSize, height: controller.openButtonSize)
                    .padding(.bottom, 4)
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
                    .foregroundColor(controller.openButtonColor.color)
            }
            .opacity(controller.showMenu ? 1 : 0)
            .padding()
            .padding(.top)
        }

        func isLandscape() -> Bool {
            return UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        }
    }
#endif

#if os(watchOS)
    public struct ContainerView: View {
        @ObservedObject var controller: MenuController

        public var body: some View {
            VStack(spacing: 0) {
                if controller.headerAtTop {
                    HStack(spacing: 0) {
                        if let titleView = controller.headerProvider() {
                            OpenButton()
                                .buttonStyle(.plain)
                                .padding(.leading, 5)
                            titleView
                        }
                    }
                    .padding(0)
                    .background(controller.headerBackgroundColor.color)
                    .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                    .background(GenericColor.systemLabel.color)
                    .shadow(
                        color: GenericColor.systemLabel.color.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 0.5
                    )
                    .zIndex(99)
                }

                viewToShow()
                    .onChange(of: controller.currentTab, perform: { _ in
                        if controller.autoClose {
                            withAnimation(.spring()) {
                                controller.showMenu = false
                            }
                        }
                    })

                if !controller.headerAtTop {
                    HStack(spacing: 0) {
                        if let titleView = controller.headerProvider() {
                            OpenButton()
                                .padding(.leading, 10)
                            titleView
                        }
                    }
                    .padding(0)
                    .background(controller.headerBackgroundColor.color)
                    .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                    .background(GenericColor.systemLabel.color)
                    .shadow(
                        color: GenericColor.systemLabel.color.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 0.5
                    )
                    .zIndex(99)
                }
            }
            .overlay(CloseButton(), alignment: .topLeading)
            .overlay(alignment: .bottomLeading) {
                if controller.headerProvider() == nil && !controller.headerAtTop {
                    OpenButton()
                        .padding(.leading, 10)
                        .padding(.bottom, 4)
                }
            }
            .overlay(alignment: .topLeading) {
                if controller.headerProvider() == nil && controller.headerAtTop {
                    OpenButton()
                        .padding(.leading)
                }
            }
            .background(Color.systemBackground)
        }

        @ViewBuilder
        func viewToShow() -> some View {
            let item = controller.menuItems.first(where: { $0.key == controller.currentTab })
            controller.viewProvider(item: item as! MenuView)
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
                    .aspectRatio(contentMode: .fit)
                    .font(.title.bold())
                    .foregroundColor(controller.openButtonColor.color)
                    .frame(width: controller.openButtonSize, height: controller.openButtonSize)
            }
            .opacity(controller.showMenu ? 0 : 1)
            .buttonStyle(.plain)
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
                    .foregroundColor(controller.openButtonColor.color)
            }
            .buttonStyle(.plain)
            .opacity(controller.showMenu ? 1 : 0)
            .padding(.leading, 10)
            .padding(.top)
        }
    }
#endif

#if os(macOS)

    public struct ContainerView: View {
        @ObservedObject var controller: MenuController
        var item: MenuItem
        @State private var showInspector = false

        public var body: some View {
            if controller.inspectorProvider() == nil {
                //
                // No Inspector
                //
                viewNoInspector(controller: controller)
            } else {
                //
                // Inspector Inspector
                //
                viewWithInspector(controller: controller)
            }
        }

        @ViewBuilder
        func viewNoInspector(controller: MenuController) -> some View {
            if let header = controller.headerProvider() {
                //
                // Title View
                //
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        header
                    }
                    .padding(0)
                    .background(controller.headerBackgroundColor.color)
                    .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                    .background(GenericColor.systemLabel.color)
                    .shadow(
                        color: GenericColor.systemLabel.color.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 0.5
                    )
                    .zIndex(99)

                    controller.viewProvider(item: item as! MenuView)
                        .onAppear(perform: {
                            // print("---- 3️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                            controller.currentTab = item.key
                        })
                        .layoutPriority(1)
                }
            } else {
                //
                // No Title View
                //
                controller.viewProvider(item: item as! MenuView)
                    .onAppear(perform: {
                        // print("---- 2️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                        controller.currentTab = item.key
                    })
                    .layoutPriority(1)
            }
        }

        @ViewBuilder
        func viewWithInspector(controller: MenuController) -> some View {
            if controller.headerProvider() == nil {
                //
                // No Title View
                //

                // Inspector without Title View
                HSplitView {
                    // Main View
                    if let i = item as? MenuView {
                        controller.viewProvider(item: i)
                            .onAppear(perform: {
                                // print("---- 2️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                                controller.currentTab = item.key
                            })
                            .layoutPriority(1)
                    }

                    // Inspector
                    if showInspector {
                        controller.inspectorProvider()
                            .frame(idealWidth: 500)
                    }
                }
                .if(controller.inspectorProvider() != nil && controller.headerProvider() == nil) { view in
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
                            controller.headerProvider()
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
                        .padding(0)
                        .background(controller.headerBackgroundColor.color)
                        .shadow(color: GenericColor.systemClear.color, radius: 0, x: 0, y: 0)
                        .background(GenericColor.systemLabel.color)
                        .shadow(
                            color: GenericColor.systemLabel.color.opacity(0.5),
                            radius: 3,
                            x: 0,
                            y: 0.5
                        )
                        .zIndex(99)

                        HSplitView {
                            if let i = item as? MenuView {
                                controller.viewProvider(item: i)
                                    .onAppear(perform: {
                                        // print("---- 3️⃣ Loading Menu: \(item.title) with key: \(item.key) ----")
                                        controller.currentTab = item.key
                                    })
                                    .layoutPriority(1)
                            }

                            if showInspector {
                                controller.inspectorProvider()
                                    .frame(idealWidth: 500)
                            }
                        }
                    }
                }
            }
        }
    }

#endif

class MyMenuController: MenuController {
    override func viewProvider(item: MenuView) -> AnyView {
        if item.key == 0 {
            return AnyView(TestView(text: "Home"))
        }

        if item.key == 1 {
            return AnyView(TestView(text: "Discover").background(.blue))
        }

        if item.key == 2 {
            return AnyView(TestView(text: "Devices").background(.gray))
        }

        if item.key == 3 {
            return AnyView(TestView(text: "Profile").background(.green))
        }

        if item.key == 4 {
            return AnyView(TestView(text: "Profile").background(.green))
        }

        if item.key == 5 {
            return AnyView(TestView(text: "Profile1").background(.green))
        }

        if item.key == 6 {
            return AnyView(TestView(text: "Profile2").background(.green))
        }

        return AnyView(EmptyView())
    }

    override func sideHeaderProvider() -> AnyView? {
        return AnyView(SideHeaderView())
    }

    override func sideFooterProvider() -> AnyView? {
        return AnyView(SideFooterView())
    }

    override func headerProvider() -> AnyView? {
        // return nil
        return AnyView(HeaderView())
    }

    override func inspectorProvider() -> AnyView? {
        return nil
        // return AnyView(Inspector())
    }
}

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
            MenuView(key: 5, title: "Profile3", icon: "logo"),
            MenuView(key: 6, title: "Profile4", icon: "logo"),

            MenuDivider(color: GenericColor.systemLabel),
            MenuAction(key: 101, title: "Login", systemIcon: "rectangle.portrait.and.arrow.right"),

            MenuAction(key: 102, title: "Logout", systemIcon: "pippo"),

            MenuDivider(color: .systemRed),
            MenuAction(key: 103, title: "Kill!", icon: "logo"),
        ]

        #if os(iOS) || os(watchOS)
            let x = MyMenuController(menuItems: menuItems,
                                     headerAtTop: true,
                                     openButtonSize: 30,
                                     backgroundColor: .systemBackground,
                                     itemsColor: .systemLabel,
                                     headerBackgroundColor: .systemGreen)

        #endif
        #if os(macOS)

            let x = MyMenuController(menuItems: menuItems,
                                     backgroundColor: .systemBackground,
                                     itemsColor: .systemLabel,
                                     headerBackgroundColor: .systemCyan)

        #endif

        _controller = StateObject(wrappedValue: x)
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
            Text("Test !")
                .font(.title2.bold())
                .foregroundColor(.red)
                .padding(.trailing, 10)
        }
        .background(.green)
    }
}

struct SideHeaderView: View {
    var body: some View {
        HStack {
            Text("This is Side Header View")
        }
        #if os(iOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        #endif
        #if os(watchOS)
        .font(.system(size: 14))
        .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
        #endif
        #if os(macOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        #endif
    }
}

struct SideFooterView: View {
    var body: some View {
        HStack(alignment: .center) {
            Text("This is Side Footer View")
            #if os(watchOS)

            #endif
        }
        #if os(iOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        #endif
        #if os(watchOS)
        .font(.system(size: 14))
        .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
        #endif
        #if os(macOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        #endif
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("This is the Header View")
        }
        #if os(iOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        #endif
        #if os(watchOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        .font(.system(size: 12))
        #endif
        #if os(macOS)
        .frame(maxWidth: .infinity, minHeight: 35)
        #endif
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
                .previewInterfaceOrientation(.portrait)

            MainViewContainer()
                .preferredColorScheme(.dark)
        }
    }
}

struct TestView: View {
    @State var text: String

    #if os(iOS)
        let gradient = LinearGradient(colors: [Color(uiColor: .systemBackground), Color(uiColor: .label)],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
    #endif

    #if os(watchOS)
        let gradient = LinearGradient(colors: [Color(uiColor: .blue), Color(uiColor: .white)],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
    #endif

    #if os(macOS)
        let gradient = LinearGradient(colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .labelColor)],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
    #endif

    var body: some View {
        ZStack {
            gradient
                .opacity(0.25)
                .ignoresSafeArea()
            Text("Your _**Moon**_ View")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
