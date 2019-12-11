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
                Section(header: Text("Prototype".uppercased())) {
                        ForEach(prototypes, id: \.self) { prototype in
                            NavigationLink(destination: PrototypeDetail(prototype: prototype).environment(\.managedObjectContext, self.context)) {
                            Text(prototype.name ?? "")
                            }
                        }.onDelete(perform: removePrototype)
                    }
                }
                .navigationBarTitle("Prototypes")
                .navigationBarItems(trailing:
                    Button("Add") {
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
