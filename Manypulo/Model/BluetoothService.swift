//
//  BluetoothService.swift
//  ObjectMotion
//
//  Created by Tassilo Bouwman on 28.02.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import SwiftUI
import Combine
import CoreBluetooth

class BluetoothService: NSObject, ObservableObject {
    
    @Published var angle: Float = 0
    @Published var toggled: Bool = false
    @Published var currentObject: String? = nil
    @Published var scannedObjects: [String] = []
    @Published var errorMessage: String? = nil
    @Published var connected: Bool = false
    
    var centralManager: CBCentralManager!

    var peripheral: CBPeripheral? {
        willSet {
            if newValue != nil {
                self.connected = true
            } else {
                self.connected = false
            }
        }
    }
        
    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        
        centralManager.delegate = self
    }
    
    var computedProperty : Bool = true {
        willSet {
            self.objectWillChange.send()
        }
    }
}

struct MotionData {
    var x: Float
    var y: Float
    var z: Float
}

extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == CBUUID(string: Const.Bluetooth.MotionService.uuid) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            switch characteristic.uuid {
            case CBUUID(string: Const.Bluetooth.AngleCharacteristic.uuid),
                 CBUUID(string: Const.Bluetooth.ObjectStartCharacteristic.uuid),
                 CBUUID(string: Const.Bluetooth.ObjectEndCharacteristic.uuid):
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        errorMessage = nil
        
        switch characteristic.uuid {
        case CBUUID(string: Const.Bluetooth.AngleCharacteristic.uuid):
            guard let data = characteristic.value else {
                errorMessage = "no data"
                return
            }
            guard let message = String(data: data, encoding: String.Encoding.ascii) else {
                errorMessage = "no encoding"
                return
            }
            
            guard let angle = Float(message.digits) else {
                errorMessage = "gyro conversion failed of \(message)"
                return
            }
            self.angle = angle
            print("Bluetooth")
            print(angle)
            
        case CBUUID(string: Const.Bluetooth.ObjectStartCharacteristic.uuid):
            errorMessage = nil
            
            guard let data = characteristic.value else {
                errorMessage = "no data"
                return
            }
            guard let idString = String(data: data, encoding: String.Encoding.ascii) else {
                errorMessage = "no encoding"
                return
            }
            let id = String(idString.prefix(12))
            self.currentObject = id
            
            if scannedObjects.contains(id) == false {
                scannedObjects.append(id)
            }
            
        case CBUUID(string: Const.Bluetooth.ObjectEndCharacteristic.uuid):
            errorMessage = nil
            
            guard let data = characteristic.value else {
                errorMessage = "no data"
                return
            }
            guard let _ = String(data: data, encoding: String.Encoding.ascii) else {
                errorMessage = "no encoding"
                return
            }
            self.toggled = !self.toggled
            self.currentObject = nil
            
        default:
            break
        }
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Manypulo-0815" {
            self.peripheral = peripheral
            self.peripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager.stopScan()
        self.peripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}

