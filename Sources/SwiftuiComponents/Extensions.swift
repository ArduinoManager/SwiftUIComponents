//
//  Extensions.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }

    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }

    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }

    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        modifier(DeviceRotationViewModifier(action: action))
    }
}

// custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}


struct NavigationButton<Destination: View, Label: View>: View {
        var action: () -> Void = { }
        var destination: () -> Destination
        var label: () -> Label

        @State private var isActive: Bool = false

        var body: some View {
                Button(action: {
                        self.action()
                        self.isActive.toggle()
                }) {
                        self.label()
                            .background(
                                ScrollView { // Fixes a bug where the navigation bar may become hidden on the pushed view
                                        NavigationLink(destination: LazyDestination { self.destination() },
                                                                                                 isActive: self.$isActive) { EmptyView() }
                                }
                            )
                }
        }
}

// This view lets us avoid instantiating our Destination before it has been pushed.
struct LazyDestination<Destination: View>: View {
        var destination: () -> Destination
        var body: some View {
                self.destination()
        }
}
