//
//  Extensions.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI
#if canImport(Cocoa)
    import Cocoa
#endif

extension View {
    #if os(iOS)
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
    #endif
}

// custom view modifier to track rotation and
// call our action
#if os(iOS)
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
#endif

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func customStyle(type: ListStyle) -> some View {
        switch type {
        case .plain:
            listStyle(.plain)
        #if os(iOS)
            case .grouped:
                listStyle(.grouped)
            case .insetGrouped:
                listStyle(.insetGrouped)
        #endif
        #if os(macOS)
            case .grouped:
                listStyle(.inset)
            case .insetGrouped:
                listStyle(.inset)
        #endif
        case .inset:
            listStyle(.inset)
        case .sidebar:
            listStyle(.sidebar)
        }
    }
}


#if os(macOS)

struct ScrollViewCleaner: NSViewRepresentable {

    func makeNSView(context: NSViewRepresentableContext<ScrollViewCleaner>) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async { // on next event nsView will be in view hierarchy
            if let scrollView = nsView.enclosingScrollView {
                scrollView.drawsBackground = false
            }
        }
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<ScrollViewCleaner>) {
    }
}

extension View {
    func removingScrollViewBackground() -> some View {
        self.background(ScrollViewCleaner())
    }
}

extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}

#endif
