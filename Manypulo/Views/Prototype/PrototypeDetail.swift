//
//  PrototypeDetail.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 08/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI
import CoreData

struct PrototypeDetail: View {
    
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bluetooth: BluetoothService
    
    @State private var name: String = ""
    @State private var showOutput = false
    
    var prototype: Prototype
    var outputsRequest : FetchRequest<Output>
    var outputs : FetchedResults<Output> { outputsRequest.wrappedValue }

    init(prototype: Prototype) {
        self.prototype = prototype
        self.outputsRequest = FetchRequest(entity: Output.entity(),
                                         sortDescriptors: [NSSortDescriptor(keyPath: \Output.action, ascending: true)],
                                         predicate: NSPredicate(format: "prototype = %@", prototype))
        self.name = prototype.name ?? "Example"
    }
        
    var body: some View {
        List {
            Section(header: Text("Name".uppercased())) {
                TextField("Name", text: $name, onEditingChanged: { (changed) in
                    self.prototype.name = self.name
                    self.save()
                }, onCommit: {
                    self.prototype.name = self.name
                    self.save()
                })
            }
            Section(header: Text("Outputs".uppercased())) {
                ForEach(outputs, id: \.self) { output in
                    NavigationLink(destination: OutputDetail(output: output, prototype: self.prototype, showModal: self.$showOutput)) {
                        OutputRow(name: output.action!,
                                  imageName: ActionType(rawValue: output.action!)!.imageName,
                                  isSelected: false,
                                  action: nil)
                    }
                }
                Button(action: { self.showOutput = true }) {
                    Text("Add Output")
                }
            }
        }
        .navigationBarItems(trailing:
            NavigationLink(destination: PrototypePlayer(prototype: self.prototype)) {
                Text("Play")
            }
        )
            .sheet(isPresented: self.$showOutput) {
                OutputDetail(prototype: self.prototype, showModal: self.$showOutput).environment(\.managedObjectContext, self.context).environmentObject(self.bluetooth)
        }
        .listStyle(GroupedListStyle())
    }
}

// MARK: - Core Data

extension PrototypeDetail {
    
//    func removeOutputs(at offsets: IndexSet) {
//        for index in offsets {
//            if let outputs = prototype.outputs {
//                let control = outputs[index]
//                context.delete(control)
//            }
//        }
//        save()
//    }
    
    func save()
    {
        do {
            try context.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct PrototypeDetail_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let prototype = Prototype(context: context)
        prototype.name = "Example"
        
        return PrototypeDetail(prototype: prototype)
    }
}


