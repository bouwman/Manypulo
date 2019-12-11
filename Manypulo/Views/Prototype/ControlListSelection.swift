//
//  ControlListSelection.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 10/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct ControlListSelection: View {
    
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bluetooth: BluetoothService
    
    @FetchRequest(
        entity: Control.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Control.id, ascending: true),
            NSSortDescriptor(keyPath: \Control.name, ascending: true)
        ]
    ) var controls: FetchedResults<Control>
    
    @Binding var selectedControl: Control?
    
    var body: some View {
            VStack {
                if bluetooth.scannedObjects.count > 0 {
                    ForEach(bluetooth.scannedObjects, id: \.self) { controlId in
                        Section(header: Text("New controls".uppercased())) {
                            if self.isControlAlreadyStored(id: controlId) {
                                HStack {
                                    Image(systemName: "questionmark")
                                    Text(controlId)
                                        .padding(8)
                                }
                                Button("Add Tag") {
                                    self.addControl(id: controlId)
                                }.padding(8)
                            }
                        }
                    }
                    
                }
                Section(header: Text("Control Type".uppercased())) {
                    ForEach(controls, id: \.self) { control in
                        ControlRow(id: control.id!, isSelected: control == self.selectedControl ) {
                            self.selectedControl = control
                        }
                    }.onDelete(perform: removeControls)
                }
            }
    }
    
    func isControlAlreadyStored(id: String) -> Bool {
        return (self.controls.contains { (existingControl) -> Bool in
            existingControl.id == id
        }) == false
    }
}

// MARK: Core Data stuff

extension ControlListSelection {
    func removeControls(at offsets: IndexSet) {
        for index in offsets {
            let control = controls[index]
            
            if let i = bluetooth.scannedObjects.firstIndex(of: control.id!) {
                bluetooth.scannedObjects.remove(at: i)
            }
            
            context.delete(control)
        }
        save()
    }
    
    func addControl(id: String) {
        let control = Control(context: context)
        control.id = id
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

struct ControlListSelection_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let control1 = Control.init(context: context)
        control1.id = "2476566"
        let control2 = Control.init(context: context)
        control2.id = "1657456"
        
        return ControlListSelection(selectedControl: .constant(control1)).environment(\.managedObjectContext, context)
    }
}
