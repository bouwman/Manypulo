//
//  PrototypeList.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 08/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI
import CoreData

struct PrototypeList: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bluetooth: BluetoothService
    
    @FetchRequest(
        entity: Prototype.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Prototype.name, ascending: true),
        ]
    ) var prototypes: FetchedResults<Prototype>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(prototypes, id: \.self) { prototype in
                    NavigationLink(destination: PrototypeDetail(prototype: prototype).environment(\.managedObjectContext, self.context)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prototype.name ?? "")
                            Text("\(prototype.outputs?.count ?? 0) outputs")
                                .foregroundColor(Color.secondary)
                                .font(.caption)
                        }
                    }
                }.onDelete(perform: removePrototype)
            }
            .navigationBarTitle("Prototypes")
            .navigationBarItems(trailing:
                Button("Add") {
                    self.addPrototype(name: "Prototype")
                }
            )
                .navigationBarItems(
                    leading:
                    Group {
                        if self.bluetooth.connected {
                            Image(systemName: "wifi")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.red)
                        }
                    }
                    ,
                    trailing: Button("Add") {
                        self.addPrototype(name: "Example")
                    }
            )
        }
        .listStyle(GroupedListStyle())
    }
}

// MARK: Core Data stuff

extension PrototypeList {
    func removePrototype(at offsets: IndexSet) {
        for index in offsets {
            let prototype = prototypes[index]
            context.delete(prototype)
        }
        save()
    }
    
    func addPrototype(name: String) {
        let prototype = Prototype(context: context)
        prototype.name = name
        save()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct PrototypeList_Previews: PreviewProvider {
    static var previews: some View {
        PrototypeList()
    }
}
