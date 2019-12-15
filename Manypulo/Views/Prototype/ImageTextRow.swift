//
//  OutputRow.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 07/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI

struct ImageTextRow: View {
    
    var text: String
    var imageName: String
    var isSelected: Bool
    var action: (() -> Void)?
    
    var body: some View {
        Group {
            if action == nil {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: imageName)
                        .frame(width: 24, height: 24)
                    Text(text)
                    if isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            } else {
                Button(action: action!) {
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: imageName)
                            .frame(width: 24, height: 24)
                        Text(text)
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
        return ImageTextRow(text: "Dial", imageName: "dial", isSelected: true) {
        }
    }
}
