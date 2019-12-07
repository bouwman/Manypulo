//
//  ContentView.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    private var database = ControlDatabase()
    
    var body: some View {
        TabView(selection: $selection){
            NavigationView() {
            List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                Image(systemName: "photo")
                    .padding(.trailing, 16.0)
                    .padding(.leading, 8.0)
                VStack(alignment: .leading) {
                    Text("First View")
                        .font(.body)
                    .tag(0)
                    Text("Subtitle")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                .padding(.vertical, 8.0)
            }
            }
            .tabItem {
                VStack {
                    Image("first")
                    Text("First")
                }
            }
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Second")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
