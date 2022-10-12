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

#if os(iOS)
    let iconSize: CGFloat = 25.0
#endif
#if os(watchOS)
    let iconSize: CGFloat = 20.0
#endif
#if os(macOS)
    let iconSize: CGFloat = 18.0
#endif

#if os(watchOS)
    typealias UIDeviceOrientation = Int
#endif

extension View {
    #if os(iOS)

        func hasNotch() -> Bool {
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
            let bottom = keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 20
        }

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

    #if os(watchOS)

        func hasNotch() -> Bool {
            return true
        }

        func getRect() -> CGRect {
            return WKInterfaceDevice.current().screenBounds
        }

        func getSafeArea() -> UIEdgeInsets {
            return .zero
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

#if os(watchOS)
    struct DeviceRotationViewModifier: ViewModifier {
        let action: (UIDeviceOrientation) -> Void

        func body(content: Content) -> some View {
            content
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
        func customStyle(type: ListComponentStyle, alternateRow: Bool = false) -> some View {
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

    #if os(watchOS)
        @ViewBuilder
        func customStyle(type: ListComponentStyle, alternateRow: Bool = false) -> some View {
            switch type {
            case .plain:
                listStyle(.plain)
            case .grouped:
                listStyle(.plain)
            case .insetGrouped:
                listStyle(.plain)
            case .inset:
                listStyle(.plain)
            case .sidebar:
                listStyle(.plain)
            }
        }
    #endif

    #if os(macOS)
        @ViewBuilder
        func customStyle(type: ListComponentStyle, alternateRow: Bool = false) -> some View {
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
            enclosingScrollView?.drawsBackground = false
        }
    }

#endif

func getSafeSystemImage(systemName: String) -> Image {
    #if os(macOS)
        if let nsImage = NSImage(systemSymbolName: systemName, accessibilityDescription: "") {
            return Image(nsImage: nsImage)
                .resizable()
        } else {
            return Image(systemName: "questionmark.app.dashed")
                .resizable()
        }
    #endif
    #if os(iOS) || os(watchOS)
        if let _ = UIImage(systemName: systemName) {
            return Image(systemName: systemName)
                .resizable()
        } else {
            return Image(systemName: "questionmark.app.dashed")
                .resizable()
        }
    #endif
}

func getSafeImage(name: String) -> Image {
    #if os(macOS)
        if let nsImage = NSImage(named: name) {
            return Image(nsImage: nsImage)
                .resizable()
        } else {
            return Image(systemName: "seal")
                .resizable()
        }
    #endif
    #if os(iOS) || os(watchOS)
        if let _ = UIImage(named: name) {
            return Image(name)
                .resizable()
        } else {
            return Image(systemName: "seal")
                .resizable()
        }
    #endif
}

@ViewBuilder
func makeImage(action: ListAction, iconSize: CGFloat, color: GenericColor) -> some View {
    if action.icon != nil {
        getSafeImage(name: action.icon!)
            .aspectRatio(contentMode: .fit)
            .padding(3)
            .foregroundColor(color.color)
            .frame(width: iconSize + 1, height: iconSize + 1)
            .border(color.color, width: 1)
    } else {
        if let icon = action.systemIcon {
            getSafeSystemImage(systemName: icon)
                .aspectRatio(contentMode: .fit)
                .padding(3)
                .foregroundColor(color.color)
                .frame(width: iconSize + 1, height: iconSize + 1)
                .border(color.color, width: 1)
        }
    }
}

extension Color {
    #if os(macOS)
        typealias SystemColor = NSColor
    #else
        typealias SystemColor = UIColor
    #endif

    public var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        #if os(iOS)
            SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        #if os(watchOS)
            SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        #if os(macOS)

            let c1 = SystemColor(self).usingColorSpace(NSColorSpace.deviceRGB)
            guard c1 != nil else {
                return nil
            }
            c1!.getRed(&r, green: &g, blue: &b, alpha: &a)
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

#if os(iOS)
    extension UIDevice {
        var hasNotch: Bool {
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
            let bottom = keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 20
        }
    }
#endif
