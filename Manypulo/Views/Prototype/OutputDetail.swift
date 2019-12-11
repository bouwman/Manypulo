//
//  OutputDetail.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 09/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct OutputDetail: View {
    
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @FetchRequest(
        entity: Control.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Control.id, ascending: true),
            NSSortDescriptor(keyPath: \Control.name, ascending: true)
        ]
    ) var controls: FetchedResults<Control>
    
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bluetooth: BluetoothService
    
    var output: Output?
    var prototype: Prototype?
    
    @Binding var showModal: Bool
    
    @State private var action: String = ""
    @State private var value: Double = 0.0
    @State private var selectedControl: Control?
    @State private var selectedActionType: ActionType = .playPause
    @State private var allActionTypes: [ActionType] = ActionType.allCases
    
    init(output: Output? = nil, prototype: Prototype? = nil, showModal: Binding<Bool>) {
        self._showModal = showModal
        self.prototype = prototype
        
        guard let output = self.output else { return }
        self.action = output.action ?? ""
        self.selectedActionType = ActionType(rawValue: output.action!)!
        self.value = output.value
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Value".uppercased())) {
                    TextField("Value", value: $value, formatter: OutputDetail.formatter)
                }
                Section(header: Text("Output".uppercased())) {
                    ForEach(self.allActionTypes, id: \.self) { aAction in
                        OutputRow(name: aAction.name,
                                  imageName: aAction.imageName,
                                  isSelected: aAction == self.selectedActionType) {
                                    self.selectedActionType = aAction
                                    self.output?.action = aAction.rawValue
                        }
                    }
                    .onDisappear() {
                        self.output?.action = self.action
                        self.save()
                    }
                }
                Section(header: Text("Controls".uppercased())) {
                    if bluetooth.scannedObjects.count > 0 {
                        ForEach(bluetooth.scannedObjects, id: \.self) { controlId in
                            VStack {
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
                    ForEach(controls, id: \.self) { control in
                        ControlRow(id: control.id!, isSelected: control == self.selectedControl ) {
                            self.selectedControl = control
                        }
                    }.onDelete(perform: removeControls)
                }
            }
            .navigationBarItems(leading:
                Button(action: { self.showModal = false }) {
                    Text("Dismiss")
                }
            )
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        self.saveOutput()
                        self.showModal = false
                        
                    }) {
                        Text("Save")
                    }
                }
            )
                .navigationBarTitle("Define Output", displayMode: .inline)
                .listStyle(GroupedListStyle())
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
    
    func load()
    {
        guard let output = self.output else { return }
        self.action = output.action ?? ""
        self.selectedActionType = ActionType(rawValue: output.action!)!
        self.value = output.value
    }
    
    func saveOutput() {
        let output = Output(context: context)
        output.value = self.value
        output.action = self.selectedActionType.rawValue
        output.prototype = self.prototype
        
        save()
    }
    
    func addControl(id: String) {
        let control = Control(context: context)
        control.id = id
        save()
    }
    
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
    
    func save()
    {
        do {
            try context.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func isControlAlreadyStored(id: String) -> Bool {
        return (self.controls.contains { (existingControl) -> Bool in
            existingControl.id == id
        }) == false
    }
}

struct OutputDetail_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let output = Output(context: context)
        output.value = 5
        output.action = ActionType.nextSong.rawValue
        
        return OutputDetail(output: output, showModal: .constant(true))
    }
}
