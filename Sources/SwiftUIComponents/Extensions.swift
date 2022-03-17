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

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
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

    #if os(iOS)
        @ViewBuilder
        func customStyle(type: ListStyle, alternateRow: Bool = false) -> some View {
            switch type {
            case .plain:
                listStyle(.plain)
            case .grouped:
                listStyle(.grouped)
            case .insetGrouped:
                listStyle(.insetGrouped)
            case .inset:
                listStyle(.inset)
            case .sidebar:
                listStyle(.sidebar)
            }
        }
    #endif

    #if os(macOS)
        @ViewBuilder
        func customStyle(type: ListStyle, alternateRow: Bool = false) -> some View {
            switch type {
            case .plain:
                listStyle(.plain)
            case .inset:
                listStyle(.inset)
            case .grouped:
                listStyle(.inset)
            case .insetGrouped:
                listStyle(.inset)
            case .sidebar:
                listStyle(.sidebar)
            }
        }
    #endif
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
            background(ScrollViewCleaner())
        }
    }

    extension NSTableView {
        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()

            backgroundColor = NSColor.clear
            enclosingScrollView!.drawsBackground = false
        }
    }

#endif

extension Color {
    var inverted: Color {
        let r = components.0
        let g = components.1
        let b = components.2
        let a = components.3

        return Color(.sRGB, red: 1 - r, green: 1 - g, blue: 1 - b, opacity: a)
    }

    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if canImport(UIKit)
            typealias NativeColor = UIColor
        #elseif canImport(AppKit)
            typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        #if os(iOS)
            guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
                // You can handle the failure here as you want
                return (0, 0, 0, 0)
            }
        #endif

        #if os(macOS)
            if let x = NativeColor(self).usingColorSpace(NSColorSpace.deviceRGB) {
                x.getRed(&r, green: &g, blue: &b, alpha: &o)
            }
        #endif

        return (r, g, b, o)
    }
}

func getSafeSystemImage(systemName: String) -> Image {
    #if os(macOS)
        if let nsImage = NSImage(named: systemName) {
            return Image(nsImage: nsImage)
        } else {
            return Image(systemName: "questionmark.app.dashed")
        }
    #endif
    #if os(iOS)
        if let uiImage = UIImage(systemName: systemName) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "questionmark.app.dashed")
        }
    #endif
}

func getSafeImage(name: String) -> Image {
    #if os(macOS)
        if let nsImage = NSImage(named: name) {
            return Image(nsImage: nsImage)
        } else {
            return Image(systemName: "questionmark.app.dashed")
        }
    #endif
    #if os(iOS)
        if let uiImage = UIImage(named: name) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "questionmark.app.dashed")
        }
    #endif
}
