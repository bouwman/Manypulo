//
//  ObjectDatabase.swift
//  ObjectMotion
//
//  Created by Tassilo Bouwman on 30.03.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import Foundation

struct ControlS {
    var id: String
    var controlType: ControlType
}

enum ControlType {
    case onOff, continuous, unknown
}

class ControlDatabase {
    
    var controls = [ControlS]()
    
    func findControlFor(id: String) -> ControlS? {
        return controls.first(where: { $0.id == id })
    }
    
    static func sampleControls() -> [ControlS] {
        return [ControlS(id: "445c6a2d4d81", controlType: .onOff),
                ControlS(id: "4e45c6a2d4d8", controlType: .continuous),
                ControlS(id: "441436a2d4d8", controlType: .continuous),
                ControlS(id: "43b436a2d4d8", controlType: .continuous),
                ControlS(id: "4f65c6a2d4d8", controlType: .continuous),
                ControlS(id: "4ea5c6a2d4d8", controlType: .continuous)]
    }
}
