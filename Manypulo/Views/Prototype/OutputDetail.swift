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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var bluetooth: BluetoothService
    
    var output: Output?
    var prototype: Prototype?
    
    @Binding var showModal: Bool
    
    @State private var value: Double = 0.0
    @State private var selectedControlId: String?
    @State private var selectedActionType: ActionType = .playPause
    
    init(output: Output? = nil, prototype: Prototype? = nil, showModal: Binding<Bool>) {
        self.output = output
        self.prototype = prototype
        self._showModal = showModal
    }
    
    var body: some View {
        Group {
            if self.showModal {
                NavigationView {
                    mainView
                        .navigationBarTitle("Define Output", displayMode: .inline)
                        .listStyle(GroupedListStyle())
                        .navigationBarItems(
                            leading: Button("Cancel") {
                                self.showModal = false
                            },
                            trailing: Button("Save") {
                                self.addOutput()
                                self.showModal = false
                            }
                            .disabled(selectedControlId == nil)
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                mainView
            }
        }
        .onAppear() {
            self.load()
        }
    }
}

extension OutputDetail {
    var mainView: some View {
        Form {
            Section(header: Text("Value".uppercased())) {
                TextField("Value", value: $value, formatter: OutputDetail.formatter)
            }
            Section(header: Text("Output".uppercased())) {
                Picker(
                    selection: self.$selectedActionType,
                    label: Text("Out")
                ) {
                    ForEach(ActionType.allCases, id: \.self) {
                        ImageTextRow(text: $0.name, imageName: $0.imageName, isSelected: false, action: nil).tag($0)
                    }
                }
            }
            
            Section(header: Text("Controls".uppercased())) {
                Picker(
                    selection: self.$selectedControlId,
                    label: Text("Select")
                ) {
                    ForEach(Array(controls).sorted(), id: \.id) {
                        Text($0.id!).tag($0.id!)
                    }
                }
            }
            
            if thereAreNewScannedControls {
                Section(header: Text("Add Control".uppercased())) {
                    ForEach(bluetooth.scannedObjects, id: \.self) { controlId in
                        Group {
                            if !self.isControlAlreadyStored(id: controlId) {
                                HStack {
                                    Image(systemName: "questionmark")
                                    Text(controlId)
                                        .padding(8)
                                    Button(action: { self.addControl(id: controlId)}) {
                                        Image(systemName: "plus")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if !self.showModal {
                VStack(alignment: .center, spacing: 0) {
                    Button(action: deleteOutput) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

extension OutputDetail {
    func load()
    {
        guard let output = self.output else { return }
        self.selectedActionType = output.actionType
        self.value = output.value
    }
    
    func addOutput() {
        let output = Output(context: context)
        let control = self.controls.first(where: { $0.id == self.selectedControlId })
        
        output.value = self.value
        output.action = self.selectedActionType.rawValue
        output.prototype = self.prototype
        output.control = control
        
        save()
    }
    
    func deleteOutput() {
        guard let output = self.output else { return }
        context.delete(output)
        save()
        self.presentationMode.wrappedValue.dismiss()
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
            return existingControl.id == id
        })
    }
    
    var thereAreNewScannedControls: Bool {
        get {
            var newControls = false
            for controlID in bluetooth.scannedObjects {
                if isControlAlreadyStored(id: controlID) == false {
                    newControls = true
                }
            }
            return newControls
        }
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
