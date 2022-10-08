//
//  SwiftUIView.swift
//  
//
//  Created by Fabrizio Boco on 10/7/22.
//

import Introspect
import SwiftUI

class ScrollerPosition: ObservableObject {
    @Published var index: Int = 0
}

struct ScrollerView: View {
    var views: [AnyView]
    @ObservedObject var selected: ScrollerPosition

    var body: some View {
        GeometryReader { geometry in

            ScrollView([], showsIndicators: false) {
                ScrollViewReader { pageScroller in
                    HStack {
                        ForEach(0 ..< views.count, id: \.self) { idx in
                            let view = views[idx]
                            view
                                .introspectScrollView { scrollView in
                                    scrollView.isScrollEnabled = false
                                }
                                .frame(width: geometry.size.width)
                                .tag(idx)
                        }
                    }
                    .onChange(of: selected.index) { idx in
                        pageScroller.scrollTo(idx)
                    }
                }
            }
           
        }
    }
}

struct ScrollerContainer: View {
    @State private var position = ScrollerPosition()
    
    var views = [
        AnyView(Text("A")),
        AnyView(Text("B")),
        AnyView(Text("C")),
        AnyView(Text("D"))
    ]

    var body: some View {
        ScrollerView(views: views, selected: position)
    }
}

struct ScrollerView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollerContainer()
    }
}
