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
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }

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

// extension Color {
//    var inverted: Color {
//        let r = components.0
//        let g = components.1
//        let b = components.2
//        let a = components.3
//
//        return Color(.sRGB, red: 1 - r, green: 1 - g, blue: 1 - b, opacity: a)
//    }
//
//    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
//        #if canImport(UIKit)
//            typealias NativeColor = UIColor
//        #elseif canImport(AppKit)
//            typealias NativeColor = NSColor
//        #endif
//
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        var o: CGFloat = 0
//
//        #if os(iOS)
//            guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
//                // You can handle the failure here as you want
//                return (0, 0, 0, 0)
//            }
//        #endif
//
//        #if os(macOS)
//            if let x = NativeColor(self).usingColorSpace(NSColorSpace.deviceRGB) {
//                x.getRed(&r, green: &g, blue: &b, alpha: &o)
//            }
//        #endif
//
//        return (r, g, b, o)
//    }
// }

func getSafeSystemImage(systemName: String) -> Image {
    #if os(macOS)
        if let nsImage = NSImage(systemSymbolName: systemName, accessibilityDescription: "") {
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
            return Image(systemName: "seal")
        }
    #endif
    #if os(iOS)
        if let uiImage = UIImage(named: name) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "seal")
        }
    #endif
}

@ViewBuilder
func makeImage(action: ListAction, iconSize: CGFloat) -> some View {
    if action.icon != nil {
        getSafeImage(name: action.icon!)
            .resizable()
            .scaledToFit()
            .frame(width: iconSize + 1, height: iconSize + 1)
    } else {
        if let icon = action.systemIcon {
            getSafeSystemImage(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        }
    }
}

fileprivate extension Color {
    #if os(macOS)
        typealias SystemColor = NSColor
    #else
        typealias SystemColor = UIColor
    #endif

    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        #if os(macOS)
            SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
        #else
            let c1 = usingColorSpace(NSColorSpace.deviceRGB)
            guard c1 != nil else {
                return nil
            }
            guard c1.getRed(&r, green: &g, blue: &b, alpha: &a) else {
                // Pay attention that the color should be convertible into RGB format
                // Colors using hue, saturation and brightness won't work
                return nil
            }
        #endif

        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)

        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        if let components = colorComponents {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(components.0, forKey: .red)
            try container.encode(components.1, forKey: .green)
            try container.encode(components.2, forKey: .blue)
        }
    }
}
