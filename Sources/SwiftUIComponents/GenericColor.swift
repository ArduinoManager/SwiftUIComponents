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
        case background
        case label
        case secondaryLabel
        case tertiaryLabel
        case quaternaryLabel
        case clear
        
        case none
    }

    private var customColor: Color?
    private var _systemColor: SystemColor?

    public var color: Color {
        if let c = customColor {
            return c
        } else {
            #if os(iOS)
                switch _systemColor! {
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
                case .background:
                    return .backgroundColor
                case .label:
                    return .label
                case .secondaryLabel:                    
                    return Color(uiColor: .secondaryLabel)
                case .tertiaryLabel:
                    return Color(uiColor: .tertiaryLabel)
                case .quaternaryLabel:
                    return Color(uiColor: .quaternaryLabel)
                case .clear:
                    return Color(uiColor: .clear)
                    
                case .none:
                    return Color(uiColor: .clear)
                }
            #endif

            #if os(macOS)

                switch _systemColor! {
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
                    return Color(nsColor: .systemGray)
                case .systemGray3:
                    return Color(nsColor: .systemGray)
                case .systemGray4:
                    return Color(nsColor: .systemGray)
                case .systemGray5:
                    return Color(nsColor: .systemGray)
                case .systemGray6:
                    return Color(nsColor: .systemGray)
                case .background:
                    return .backgroundColor
                case .label:
                    return .label
                case .secondaryLabel:
                    return Color(nsColor: .lightGray)
                case .tertiaryLabel:
                    return Color(nsColor: .lightGray)
                case .quaternaryLabel:
                    return Color(nsColor: .lightGray)
                case .clear:
                    return Color(nsColor: .clear)
                    
                case .none:
                    return Color(nsColor: .clear)
                }
            #endif
        }
    }

    public var systemColor: SystemColor {
        return _systemColor ?? .none
    }
    
    public init(color: Color) {
        self.customColor = color
        self._systemColor = nil
    }
    
    public init(systemColor: SystemColor) {
        self.customColor = nil
        self._systemColor = systemColor
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
// MARK: --
    
    public static let background = GenericColor(systemColor: .background)
    public static let label = GenericColor(systemColor: .label)
    public static let red = GenericColor(systemColor: .systemRed)
    public static let clear = GenericColor(systemColor: .clear)
    
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
