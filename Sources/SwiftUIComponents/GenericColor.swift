//
//  GenericColor.swift
//  SwiftUIDesigner
//
//  Created by Fabrizio Boco on 4/7/22.
//

import SwiftUI

/// Useful link: https://mar.codes/apple-colors

public class GenericColor: Codable {
    public enum SystemColor: String, CaseIterable, Codable {
        case none

        case systemClear
        case systemLabel
        case systemSecondaryLabel
        case systemTertiaryLabel
        case systemBackground
        case systemQuaternaryLabel

        case systemTint
        case systemRed
        case systemBlue
        case systemGreen
        case systemOrange
        case systemYellow
        case systemPink
        case systemPurple
        case systemTeal
        case systemIndigo
        case systemBrown
        case systemMint
        case systemCyan
        case systemGray
        case systemGray2
        case systemGray3
        case systemGray4
        case systemGray5
        case systemGray6
    }

    private var customColor: Color?
    private var _systemColor: SystemColor?

    public var color: Color {
        if let c = customColor {
            return c
        } else {
            #if os(iOS)
                switch _systemColor! {
                case .none:
                    return Color(uiColor: .clear)
                case .systemClear:
                    return Color(uiColor: .clear)
                case .systemLabel:
                    return .systemLabel
                case .systemBackground:
                    return .systemBackground
                case .systemTint:
                    return Color(uiColor: .tintColor)
                case .systemRed:
                    return Color(uiColor: .systemRed)
                case .systemBlue:
                    return Color(uiColor: .systemBlue)
                case .systemGreen:
                    return Color(uiColor: .systemGreen)
                case .systemOrange:
                    return Color(uiColor: .systemOrange)
                case .systemYellow:
                    return Color(uiColor: .systemYellow)
                case .systemPink:
                    return Color(uiColor: .systemPink)
                case .systemPurple:
                    return Color(uiColor: .systemPurple)
                case .systemTeal:
                    return Color(uiColor: .systemTeal)
                case .systemIndigo:
                    return Color(uiColor: .systemIndigo)
                case .systemBrown:
                    return Color(uiColor: .systemBrown)
                case .systemMint:
                    return Color(uiColor: .systemMint)
                case .systemCyan:
                    return Color(uiColor: .systemCyan)
                case .systemGray:
                    return Color(uiColor: .systemGray)
                case .systemGray2:
                    return Color(uiColor: .systemGray2)
                case .systemGray3:
                    return Color(uiColor: .systemGray3)
                case .systemGray4:
                    return Color(uiColor: .systemGray4)
                case .systemGray5:
                    return Color(uiColor: .systemGray5)
                case .systemGray6:
                    return Color(uiColor: .systemGray6)
                case .systemSecondaryLabel:
                    return Color(uiColor: .secondaryLabel)
                case .systemTertiaryLabel:
                    return Color(uiColor: .tertiaryLabel)
                case .systemQuaternaryLabel:
                    return Color(uiColor: .quaternaryLabel)
                }
            #endif

            #if os(macOS)

                switch _systemColor! {
                case .none:
                    return Color(nsColor: .clear)
                case .systemClear:
                    return Color(nsColor: .clear)
                case .systemLabel:
                    return .systemLabel
                case .systemBackground:
                    return .systemBackground
                case .systemTint:
                    return Color(nsColor: .controlAccentColor)
                case .systemRed:
                    return Color(nsColor: .systemRed)
                case .systemBlue:
                    return Color(nsColor: .systemBlue)
                case .systemGreen:
                    return Color(nsColor: .systemGreen)
                case .systemOrange:
                    return Color(nsColor: .systemOrange)
                case .systemYellow:
                    return Color(nsColor: .systemYellow)
                case .systemPink:
                    return Color(nsColor: .systemPink)
                case .systemPurple:
                    return Color(nsColor: .systemPurple)
                case .systemTeal:
                    return Color(nsColor: .systemTeal)
                case .systemIndigo:
                    return Color(nsColor: .systemIndigo)
                case .systemBrown:
                    return Color(nsColor: .systemBrown)
                case .systemMint:
                    return Color(nsColor: .systemMint)
                case .systemCyan:
                    return Color(nsColor: .systemCyan)
                case .systemGray:
                    return Color(nsColor: .systemGray)
                case .systemGray2:
                    return Color(red: 0.6823529601097107, green: 0.6823529601097107, blue: 0.6980392336845398, opacity: 1.0)
                case .systemGray3:
                    return Color(red: 0.7803921699523926, green: 0.7803921699523926, blue: 0.800000011920929, opacity: 1.0)
                case .systemGray4:
                    return Color(red: 0.8196078538894653, green: 0.8196078538894653, blue: 0.8392157554626465, opacity: 1.0)
                case .systemGray5:
                    return Color(red: 0.8980392217636108, green: 0.8980392217636108, blue: 0.9176470637321472, opacity: 1.0)
                case .systemGray6:
                    return Color(red: 0.9490196108818054, green: 0.9490196108818054, blue: 0.9686275124549866, opacity: 1.0)
                case .systemSecondaryLabel:
                    return Color(red: 0.23529410362243652, green: 0.23529410362243652, blue: 0.26274511218070984, opacity: 0.6000000238418579)
                case .systemTertiaryLabel:
                    return Color(red: 0.23529410362243652, green: 0.23529410362243652, blue: 0.26274511218070984, opacity: 0.30000001192092896)
                case .systemQuaternaryLabel:
                    return Color(red: 0.23529410362243652, green: 0.23529410362243652, blue: 0.26274511218070984, opacity: 0.18000000715255737)
                }
            #endif
        }
    }

    public var systemColor: SystemColor {
        return _systemColor ?? .none
    }

    public init(color: Color) {
        customColor = color
        _systemColor = nil
    }

    public init(systemColor: SystemColor) {
        customColor = nil
        _systemColor = systemColor
    }

    public func toString() -> String {
        if let c = customColor {
            if let components = c.colorComponents {
                return "GenericColor(color:Color(red: \(components.red), green: \(components.green), blue: \(components.blue), opacity: \(components.alpha)))"
            }
            return ""
        } else {
            return "GenericColor(systemColor:.\(_systemColor!))"
        }
    }

    public func toStringComponents() -> String {
        if let components = color.colorComponents {
            return "GenericColor(color:Color(red: \(components.red), green: \(components.green), blue: \(components.blue), opacity: \(components.alpha)))"
        }
        return ""
    }

    // MARK: - -

    public static let systemClear = GenericColor(systemColor: .systemClear)
    public static let systemBackground = GenericColor(systemColor: .systemBackground)
    public static let systemLabel = GenericColor(systemColor: .systemLabel)
    public static let systemRed = GenericColor(systemColor: .systemRed)
    public static let systemGreen = GenericColor(systemColor: .systemGreen)
    public static let systemBlue = GenericColor(systemColor: .systemBlue)
    public static let systemYellow = GenericColor(systemColor: .systemYellow)
    public static let systemGray = GenericColor(systemColor: .systemGray)
    public static let systemCyan = GenericColor(systemColor: .systemCyan)
    public static let systemWhite = GenericColor(color: .white)
    public static let systemBlack = GenericColor(color: .black)

    // MARK: - Encodable & Decodable

    enum CodingKeys: String, CodingKey {
        case customColor
        case systemColor
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        customColor = try? container.decode(Color.self, forKey: .customColor)
        _systemColor = try? container.decode(SystemColor.self, forKey: .systemColor)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(customColor, forKey: .customColor)
        try container.encode(_systemColor, forKey: .systemColor)
    }
}

extension Color {
    #if os(macOS)
        public static let systemLabel = Color(NSColor.labelColor)
        public static let systemBackground = Color(NSColor.windowBackgroundColor)
        public static let systemSecondaryBackground = Color(NSColor.controlBackgroundColor)
    #else
        public static let systemLabel = Color(UIColor.label)
        public static let systemBackground = Color(UIColor.systemBackground)
        public static let systemSecondaryBackground = Color(UIColor.secondarySystemBackground)
    #endif
}
