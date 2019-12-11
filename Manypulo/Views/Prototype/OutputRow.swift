//
//  OutputRow.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct OutputRow: View {
    
    var name: String
    var imageName: String
    var isSelected: Bool
    var action: (() -> Void)?
    
    var body: some View {
        HStack {
            if action == nil {
                HStack() {
                    Image(systemName: imageName)
                    Text(name)
                    if isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            } else {
                Button(action: action!) {
                    HStack() {
                        Image(systemName: imageName)
                        Text(name)
                        if isSelected {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
        }
    }
}

struct OutputRow_Previews: PreviewProvider {
    static var previews: some View {
        return OutputRow(name: "Dial", imageName: "dial", isSelected: true) {
        }
    }
}
