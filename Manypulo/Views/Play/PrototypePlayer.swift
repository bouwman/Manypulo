//
//  PrototypePlayer.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 11/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI


struct PrototypePlayer: View {
    
    @EnvironmentObject var bluetooth: BluetoothService
    
    @State private var name: String = ""
    @State private var showOutput = false
    @State private var currentOutputId: String? {
        didSet {
            if let _ = currentOutputId {
                if let output = outputs.first(where: { $0.control?.id == currentOutputId }) {
                    self.currentOutput = output
                    self.currentOutputType = ActionType(rawValue: output.action!)!
                } // tag not found, ignore
            } else if let _ = oldValue, let output = currentOutput {
                if self.currentOutputType?.requiredControlType == .some(.button) {
                    output.value = 1.0
                    self.currentOutputType = ActionType(rawValue: output.action!)!
                }
            }
        }
    }
    @State private var currentOutput: Output?
    @State private var currentOutputType: ActionType?
    
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
        VStack() {
//            ForEach(self.outputs, id: \.self) { output in
//                VStack {
//                    if ActionType(rawValue: output.action!)!.requiredControlType == .button {
//                        EmptyView()
//                    }
//                }
//            }
            if currentOutput != nil {
                if currentOutputType?.requiredControlType == .some(.dial) {
                    Text(String(self.bluetooth.angle))
                    .font(.largeTitle)
                } else {
                    Toggle(isOn: self.$bluetooth.toggled) {
                        Text("")
                    }
                }
            } else {
                
            }
        }
        .onAppear() {
            self.currentOutputId = self.bluetooth.currentObject
        }
    }
}

//struct PrototypePlayer_Previews: PreviewProvider {
//    static var previews: some View {
//        PrototypePlayer()
//    }
//}
