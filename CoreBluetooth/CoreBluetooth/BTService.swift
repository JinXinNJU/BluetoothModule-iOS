//
//  BTService.swift
//  CoreBluetooth
//
//  Created by Ezio Auditore on 5/3/15.
//  Copyright (c) 2015 Ezio Auditore. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "0000fff0-0000-1000-8000-00805f9b34fb")
let Char7UUID = CBUUID(string: "0000fff7-0000-1000-8000-00805f9b34fb")
let Char1UUID = CBUUID(string: "0000fff1-0000-1000-8000-00805f9b34fb")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var Char7: CBCharacteristic?
    var Char1: CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()

        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([BLEServiceUUID])
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
//        let uuidsForBTService: [CBUUID] = [Char7UUID]
        
        if peripheral != self.peripheral {
            // Wrong peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if peripheral.services == nil || peripheral.services!.count == 0 {
            // No Services
            return
        }
        NSLog("Services in %@ is: %@", peripheral.name!, peripheral.services!.description)
        for service in peripheral.services! {
            if service.UUID == BLEServiceUUID {
                NSLog("Start scaning characteristics in (Service:%@)", service.UUID)
                peripheral.discoverCharacteristics(nil, forService: service as! CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
//        NSLog("Chacteristics in (Service:%@) is: %@", service.UUID, map(service.characteristics, {$0.UUID}).description)
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        if (error != nil) {
            NSLog("Error occours: %@", error)
            return
        }
        for characteristic in service.characteristics! {
            if characteristic.UUID == Char7UUID {
                NSLog("Get (Characteristic: %@)", characteristic.UUID)
                self.Char7 = (characteristic as! CBCharacteristic)
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
                
                // Send notification that Bluetooth is connected and all required characteristics are discovered
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
            if characteristic.UUID == Char1UUID {
                self.Char1 = characteristic as? CBCharacteristic
                var signal: UInt8 = 1
                peripheral.writeValue(NSData(bytes: &signal, length: 1), forCharacteristic: Char1!, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        for characteristic in service.characteristics! {
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        print(NSString(data: characteristic.value!, encoding:NSASCIIStringEncoding) ?? "nil")

    }

    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if error != nil {
            print(error)
            return
        }
        print("write to \(characteristic.UUID) successfully!")
        print(characteristic.value)
    }
    
    func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
    }

}
