//
//  Constants.swift
//  ArduinoBluetooth
//
//  Created by Tassilo Bouwman on 14.01.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import Foundation

struct Const {
    struct Table {
        struct Identifier {
            static let connectionCell = "connectionCell"
        }
    }
    struct Bluetooth {
        struct MotionService {
            static let uuid = "e11f4373-fcd3-4e07-b132-c25933f051b0"
        }
        struct AngleCharacteristic {
            static let uuid = "b7fe7c89-0b13-4d28-a744-9895a12b1c11"
        }
        struct ObjectStartCharacteristic {
            static let uuid = "9eb72828-1710-43c8-a4f8-277770ab697d"
        }
        struct ObjectEndCharacteristic {
            static let uuid = "9053c01e-e9b9-4970-93db-6c605b2f6498"
        }
    }
    struct Media {
        static let playlist = "Demo"
    }
    struct HomeKit {
        static let updateInterval: TimeInterval = 0.2
    }
}
