//
//  BluetoothService.swift
//  ObjectMotion
//
//  Created by Tassilo Bouwman on 28.02.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothService: NSObject {
    var peripheral: CBPeripheral?
    var centralManager: CBCentralManager!
    var delegate: BluetoothServiceDelegate?
    
    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
    }
}

protocol BluetoothServiceDelegate {
    func didReceive(angle: Float)
    func didStartInteractingWith(object: String)
    func didEndInteractingWith(object: String)
    func didFail(message: String)
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
        switch characteristic.uuid {
        case CBUUID(string: Const.Bluetooth.AngleCharacteristic.uuid):
            guard let data = characteristic.value else {
                delegate?.didFail(message: "no data")
                return
            }
            guard let message = String(data: data, encoding: String.Encoding.ascii) else {
                delegate?.didFail(message: "no encoding")
                return
            }
            
            guard let angle = Float(message.digits) else {
                delegate?.didFail(message: "gyro conversion failed of \(message)")
                return
            }
            
            delegate?.didReceive(angle: angle)
        case CBUUID(string: Const.Bluetooth.ObjectStartCharacteristic.uuid):
            
            guard let data = characteristic.value else {
                delegate?.didFail(message: "no data")
                return
            }
            guard let idString = String(data: data, encoding: String.Encoding.ascii) else {
                delegate?.didFail(message: "no encoding")
                return
            }
            let id = String(idString.prefix(12))
            
            delegate?.didStartInteractingWith(object: id)
        case CBUUID(string: Const.Bluetooth.ObjectEndCharacteristic.uuid):
            
            guard let data = characteristic.value else {
                delegate?.didFail(message: "no data")
                return
            }
            guard let idString = String(data: data, encoding: String.Encoding.ascii) else {
                delegate?.didFail(message: "no encoding")
                return
            }
            let id = String(idString.prefix(12))
            
            delegate?.didEndInteractingWith(object: id)
        default:
            break
        }
    }
}

