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
    
    //var outputBluetoothSync: OutputBluetoothSync
    var prototype: Prototype
    var outputsRequest : FetchRequest<Output>
    var outputs : FetchedResults<Output> { outputsRequest.wrappedValue }
    
    private var formatter: NumberFormatter = {
        var formtr = NumberFormatter()
        formtr.numberStyle = .none
        formtr.minimumFractionDigits = 0
        formtr.maximumFractionDigits = 0
        
        return formtr
    }()
    
    init(prototype: Prototype) {
        self.prototype = prototype
        self.outputsRequest = FetchRequest(entity: Output.entity(),
                                           sortDescriptors: [NSSortDescriptor(keyPath: \Output.action, ascending: true)],
                                           predicate: NSPredicate(format: "prototype = %@", prototype))
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 80) {
            Text(self.bluetooth.currentObject ?? "No control in range")
                .font(.headline)
            HStack(alignment: .center, spacing: 32) {
                ForEach(self.outputs, id: \.self) { output in
                    Group {
                        if output.actionType.requiredControlType == .button {
                            Image(systemName: output.actionType.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(output.control?.id == self.bluetooth.currentObject ? .primary : .secondary)
                        }
                    }
                }
            }
            ForEach(self.outputs, id: \.self) { output in
                Group {
                    if output.actionType.requiredControlType == .dial {
                        if output.control?.id == self.bluetooth.currentObject {
                            Text(self.formatAngle())
                                .font(.largeTitle)
                        } else {
                            Text(String(output.value))
                                .font(.largeTitle)
                        }
                        
                    }
                }
            }
            .onAppear() {
                //                    let binding: Binding<String?> = .constant("sdf")
                //                    self.outputBluetoothSync = OutputBluetoothSync(outputs: outputs, currentOutputId: binding, angleDelta: .constant(13.0), toggled: .constant(true))
            }
        }
    }
    
    private func writeOutput() {
        let output = outputs.first(where: { $0.control?.id == bluetooth.currentObject })
        output?.value = Double(bluetooth.angleDelta)
    }
    
    private func formatAngle() -> String {
        return self.formatter.string(from: NSNumber(value: self.bluetooth.angleDelta)) ?? "--"
    }
}

//struct PrototypePlayer_Previews: PreviewProvider {
//    static var previews: some View {
//        PrototypePlayer()
//    }
//}

struct OutputBluetoothSync {
    var outputs: FetchedResults<Output>
    
    @Binding var currentOutputId: String?
    
    @Binding var angleDelta: Float {
        didSet {
            let output = outputs.first(where: { $0.control?.id == currentOutputId })
            output?.value = Double(angleDelta)
        }
    }
    
    @Binding var toggled: Bool {
        didSet {
            guard let output = outputs.first(where: { $0.control?.id == currentOutputId }) else { return }
            
            if output.actionType.requiredControlType == .button {
                output.value = (output.value > 0.0) ? 0 : 1
            }
        }
    }
}
