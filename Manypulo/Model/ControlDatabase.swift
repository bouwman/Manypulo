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
    case defrost, grill, W600, W800, duration, startStop , playPause, nextSong, previousSong, volume, dimmingLight, onOffLight
    
    static var allCases: [ActionType] {
        return [defrost, grill, W600, W800, duration, startStop, playPause, nextSong, previousSong, volume, dimmingLight, onOffLight]
    }
    
    var requiredControlType: ControlType {
        switch self {
        case .playPause: return .button
        case .nextSong: return .button
        case .onOffLight: return .button
        case .previousSong: return .button
        case .volume: return .dial
        case .dimmingLight: return .dial
        case .W600: return .button
        case .W800: return .button
        case .defrost: return .button
        case .grill: return .button
        case .startStop: return .button
        case .duration: return .dial
        }
    }
    
    var name: String {
        switch self {
        case .playPause: return "Play/Pause"
        case .nextSong: return"Next Song"
        case .onOffLight: return"On/Off Light"
        case .previousSong: return "Previous Song"
        case .volume: return "Volume"
        case .dimmingLight: return "Dimming Light"
        case .W600: return "600W"
        case .W800: return "800W"
        case .defrost: return "Defrost"
        case .grill: return "Grill"
        case .startStop: return "Start/Stop"
        case .duration: return "Duration"
        }
    }
    
    var imageName: String {
        switch self {
        case .defrost: return "snow"
        case .W600: return "thermometer"
        case .W800: return "thermometer"
        case .dimmingLight: return "light.min"
        case .duration: return "timer"
        case .grill: return "text.justify"
        case .nextSong: return "forward.end"
        case .onOffLight: return "lightbulb"
        case .playPause: return "playpause"
        case .previousSong: return "backward.end"
        case .startStop: return "circle"
        case .volume: return "dial"
        }
    }
}
