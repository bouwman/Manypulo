//
//  ObjectDatabase.swift
//  ObjectMotion
//
//  Created by Tassilo Bouwman on 30.03.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import Foundation
import SwiftUI

struct ControlS {
    var id: String
    var controlType: ControlType
}

enum ControlType : String {
    case button
    case dial
    case undefined
    
    static var allCases: [ControlType] {
        return [.button, .dial, .undefined]
    }
        
    var name: String {
        switch self {
        case .button:
            return "Button"
        case .dial:
            return "Dial"
        case .undefined:
            return "Undefined"
        }
    }
    
    var imageName: String {
        switch self {
        case .button:
            return "hand.point.left"
        case .dial:
            return "dial"
        case .undefined:
            return "questionmark"
        }
    }
}

enum ActionType: String {
    case undefined, playPause, nextSong, previousSong, volume, dimmingLight, onOffLight
    
    static var allCases: [ActionType] {
        return [undefined, playPause, nextSong, previousSong, volume, dimmingLight, onOffLight]
    }
    
    var requiredControlType: ControlType {
        switch self {
        case .undefined: return .undefined
        case .playPause: return .button
        case .nextSong: return .button
        case .onOffLight: return .button
        case .previousSong: return .button
        case .volume: return .dial
        case .dimmingLight: return .dial
        }
    }
    
    var name: String {
        switch self {
        case .undefined: return "undefined"
        case .playPause: return "Play/Pause"
        case .nextSong: return"Next Song"
        case .onOffLight: return"On/Off Light"
        case .previousSong: return "Previous Song"
        case .volume: return "Volume"
        case .dimmingLight: return "Dimming Light"
        }
    }
    
    var imageName: String {
        switch requiredControlType {
        case .button:
            return "hand.point.left"
        case .dial:
            return "dial"
        case .undefined:
            return "questionmark"
        }
    }
}
