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
    
    var prototype: Prototype
    var outputsRequest : FetchRequest<Output>
    var outputs : FetchedResults<Output> { outputsRequest.wrappedValue }
    
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
            HStack(alignment: .center, spacing: 24) {
                ForEach(self.outputs, id: \.self) { output in
                    Group {
                        if output.actionType.requiredControlType == .button {
                            Image(systemName: output.actionType.imageName)
                                .frame(width: 40, height: 40)
                                .opacity(output.value > 0 ? 1.0 : 0.34)
                        }
                    }
                }
            }
            ForEach(self.outputs, id: \.self) { output in
                Group {
                    if output.actionType.requiredControlType == .dial {
                        Text(String(output.value))
                            .font(.largeTitle)
                    }
                }
            }
        }
    }
    
    //    private func isCurrentOutput(id: String?) {
    //        return outputs.first(where: { $0.control?.id == id }) != nil
    //    }
}

//struct PrototypePlayer_Previews: PreviewProvider {
//    static var previews: some View {
//        PrototypePlayer()
//    }
//}
