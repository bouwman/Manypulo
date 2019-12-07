//
//  ControlList.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct ControlList: View {
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(
        entity: Control.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Control.id, ascending: true),
            NSSortDescriptor(keyPath: \Control.name, ascending: false)
        ]
    ) var controls: FetchedResults<Control>
    
    var body: some View {
        NavigationView() {
            List(controls, id: \.self) { control in
                Image(systemName: "photo")
                    .padding(.trailing, 16.0)
                    .padding(.leading, 8.0)
                VStack(alignment: .leading) {
                    Text(control.name ?? "Noname")
                        .font(.body)
                        .tag(0)
                    Text(control.id ?? "xxxxxxxx")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                .padding(.vertical, 8.0)
            }
            .navigationBarTitle("Controls")
            .navigationBarItems(trailing:
                Button("Add") {
                    let control = Control.init(context: self.context)
                    control.id = "sadfas"
            })
        }
    }
}

struct ControlList_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let control = Control.init(context: context)
        control.id = "sadfas"
        return ControlList()
    }
}
