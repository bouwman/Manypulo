//
//  ControlDetail.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct ControlDetail: View {
    
    @Environment(\.managedObjectContext) var context
    
    var control: Control
    
    @State private var name: String = ""
    @State private var items: [ControlType] = ControlType.allCases
    @State private var selectedType: ControlType = .undefined
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    
    var body: some View {
        List() {
            Section(header: Text("Name".uppercased())) {
                TextField("Name", value: $name, formatter: formatter, onEditingChanged: { (changed) in
                    self.control.name = self.name
                    self.save()
                }, onCommit: {
                    self.control.name = self.name
                    self.save()
                })
            }
            
            
        }
        .onAppear(perform: self.load)
        .navigationBarTitle(control.id!)
    .navigationBarItems(trailing:
        HStack {
            Button(action: {
                self.save()
            }) {
                Text("Save")
            }
    })
        .listStyle(GroupedListStyle())
        
    }
    
    func load()
    {
        self.name = control.name ?? "Unknown"
    }
    
    func save()
    {
        do {
            try context.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct ControlDetail_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let control = Control.init(context: context)
        control.id = "sadfas"
        control.name = "New asdf"
        
        return ControlDetail(control: control)
    }
}
