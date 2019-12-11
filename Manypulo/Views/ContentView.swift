//
//  ContentView.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selection = 0
    
    @Environment(\.managedObjectContext) var context

    var body: some View {
//        TabView(selection: $selection){
//            ControlList()
//            .tabItem {
//                VStack {
//                    Image("first")
//                    Text("First")
//                }
//            }
//            .tag(0)
            PrototypeList()
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Second")
                    }
                }
//                .tag(1)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
