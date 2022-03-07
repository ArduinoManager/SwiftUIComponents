//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/7/22.
//

import Foundation
import SwiftUI

public class TabItem: Hashable {
    var title: String
    var systemIcon: String
    var tab: AnyView
    
    public static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.title == rhs.title
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    public init(title: String, systemIcon: String, tab: AnyView) {
        self.title = title
        self.systemIcon = systemIcon
        self.tab = tab
    }
    
    @ViewBuilder
    func makeTab() -> some View {
        tab
    }
}


class TabBarController: ObservableObject {
    @Published public var tabs: [TabItem]
    
    public init(views: [TabItem]) {
        self.tabs = views
    }
}


//struct TabBar: View {
//    var body: some View {
//        TabView {
//            ListSimpleView()
//                .tabItem {
//                    Label("List Simple", systemImage: "list.dash")
//                }
//
//            ListNavigationView()
//                .tabItem {
//                    Label("List Navigation", systemImage: "square.and.pencil")
//                }
//        }
//    }
//}
