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
        VStack {
            ForEach(outputs, id: \.self) { output in
                Text(String(self.bluetooth.angle))
                .font(.largeTitle)
                .padding(16)
            }
        }
    }
}

//struct PrototypePlayer_Previews: PreviewProvider {
//    static var previews: some View {
//        PrototypePlayer()
//    }
//}
