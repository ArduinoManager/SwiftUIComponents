//
//  ContainerView.swift
//  SideMenu2
//
//  Created by Fabrizio Boco on 3/5/22.
//

import SwiftUI

struct ContainerView: View {
    @ObservedObject var controller: MenuController
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        VStack(spacing: 0) {
            if controller.openMenuOnTop {
                HStack(spacing: 0) {
                    OpenButton()
                    Spacer()
                    if controller.titleView != nil {
                        controller.titleView
                    }
                }
                .padding([.horizontal], isLandscape() ? 40 : 20)
                .padding(.bottom)
                .padding(.top, isLandscape() ? 10.0 : getSafeArea().top)
            }

            TabView(selection: $controller.currentTab) {
                ForEach(controller.menuItems, id: \.self) { item in
                    item.makeView()
                        .tag(item.title)
                }
            }
            .onChange(of: controller.currentTab, perform: { _ in
                if controller.autoClose {
                    withAnimation(.spring()) {
                        controller.showMenu = false
                    }
                }
            })
            
            if !controller.openMenuOnTop {
                HStack(spacing: 0) {
                    OpenButton()
                    Spacer()
                    if controller.titleView != nil {
                        controller.titleView
                    }
                }
                .padding([.horizontal])
                .padding(.top)
                .padding(.bottom, getSafeArea().bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(CloseButton(), alignment: .topLeading)
        .background(controller.titleViewBackground)
        
    }

    @ViewBuilder
    func OpenButton() -> some View {
        Button {
            withAnimation(.spring()) {
                controller.showMenu.toggle()
            }
        } label: {
            Image(systemName: controller.openMenuIcon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .font(.title.bold())
                .foregroundColor(.black)
                .frame(width: controller.openMenuSize, height: controller.openMenuSize)
        }
        .opacity(controller.showMenu ? 0 : 1)
    }

    @ViewBuilder
    func CloseButton() -> some View {
        Button {
            withAnimation(.spring()) {
                controller.showMenu.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .font(.title.bold())
                .foregroundColor(.black)
        }
        .opacity(controller.showMenu ? 1 : 0)
        .padding()
        .padding(.top)
    }
    
    func isLandscape() -> Bool {
        return UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
    }
}

//struct ContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//.previewInterfaceOrientation(.portrait)
//    }
//}
