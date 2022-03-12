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

    @ViewBuilder
    func customStyle(type: ListStyle, alternateRow: Bool = false) -> some View {
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
            #if os(iOS)
                // listStyle(.inset)
            #endif
            #if os(macOS)
                listStyle(.inset(alternatesRowBackgrounds: false))
            #endif
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

#if os(iOS)
    extension Color {
        var inverted: Color {
            var a: CGFloat = 0.0, r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0
            return getRed(&r, green: &g, blue: &b, alpha: &a) ? UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a) : .black
        }
    }
#endif

#if os(macOS)
    extension Color {
        var inverted: Color {
            var a: CGFloat = 0.0, r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0

            if let components = self.cgColor?.components {
                r = components.0
                g = components.1
                b = components.2
                a = components.3
                return Color(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b)
            }
            return self
        }
    }
#endif

//extension Color {
//    #if canImport(UIKit)
//    var asNative: UIColor { UIColor(self) }
//    #elseif canImport(AppKit)
//    var asNative: NSColor { NSColor(self) }
//    #endif
//
//    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        let color = asNative.usingColorSpace(.deviceRGB)!
//        var t = (CGFloat(), CGFloat(), CGFloat(), CGFloat())
//        color.getRed(&t.0, green: &t.1, blue: &t.2, alpha: &t.3)
//        return t
//    }
//
//    var hsva: (hue: CGFloat, saturation: CGFloat, value: CGFloat, alpha: CGFloat) {
//        let color = asNative.usingColorSpace(.deviceRGB)!
//        var t = (CGFloat(), CGFloat(), CGFloat(), CGFloat())
//        color.getHue(&t.0, saturation: &t.1, brightness: &t.2, alpha: &t.3)
//        return t
//    }
//}

extension CGColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let ciColor = CIColor(cgColor: self)
        return (ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
    }
}
