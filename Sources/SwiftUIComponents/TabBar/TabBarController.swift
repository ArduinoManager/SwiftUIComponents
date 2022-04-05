//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

public class TabBarController: ObservableObject {
    @Published public var tabs: [TabItem]
    var backgroundColor: Color
    var itemsColor: Color
    
    #if os(iOS)
    public init(views: [TabItem], backgroundColor: Color = Color(uiColor: .systemBackground), itemsColor: Color = Color(uiColor: .label)) {
        self.tabs = views
        self.backgroundColor = backgroundColor
        self.itemsColor = itemsColor
    }
    #endif
    #if os(macOS)
    public init(views: [TabItem], backgroundColor: Color = Color(NSColor.windowBackgroundColor), itemsColor: Color = Color(NSColor.labelColor)) {
        self.tabs = views
        self.backgroundColor = backgroundColor
        self.itemsColor = itemsColor
    }
    #endif
}
