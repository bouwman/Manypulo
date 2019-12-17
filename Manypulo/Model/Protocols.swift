//
//  Protocols.swift
//  ArduinoBluetooth
//
//  Created by Tassilo Bouwman on 14.01.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import Foundation

protocol AngleTranslationProtocol: class {
    var angleTransmissionJustStarted: Bool { get set }
    var startAngle: Float { get set }
    
    func angleChangeFromCurrent(angle: Float) -> Float
}

extension AngleTranslationProtocol {
    func angleChangeFromCurrent(angle: Float) -> Float {
        var difference = angle - startAngle
        if difference > 90 {
            difference -= 180
        } else if difference < -90 {
            difference += 180
        }
        
        return difference
    }
}
