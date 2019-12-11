//
//  ControlRow.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct ControlRow: View {
    
    var id: String
    var isSelected: Bool
    var action: (() -> Void)?
    
    var body: some View {
        VStack {
            if action == nil {
                HStack() {
                    Text(id)
                    if isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            } else {
                Button(action: action!) {
                    HStack() {
                        Text(id)
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

struct ControlRow_Previews: PreviewProvider {
    static var previews: some View {
        return ControlRow(id: "Id", isSelected: true)
    }
}

