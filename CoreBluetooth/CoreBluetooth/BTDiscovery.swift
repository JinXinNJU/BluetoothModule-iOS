//
//  BTDiscovery.swift
//  CoreBluetooth
//
//  Created by Ezio Auditore on 5/3/15.
//  Copyright (c) 2015 Ezio Auditore. All rights reserved.
//

import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = BTDiscovery();
class BTDiscovery: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager?
    var peripheralBLE: CBPeripheral?
    var peripherals:[CBPeripheral] = []
    
    var bleService: BTService? {
        didSet {
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // scan all devices
    func startScaning() {
        if let central = centralManager {
//            central.scanForPeripheralsWithServices([BLEServiceUUID], options: nil)
            central.scanForPeripheralsWithServices(nil, options: nil)
            NSLog("Starting search for nearby peripherals with [%@]", BLEServiceUUID)
        }
    }
    
    
    func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
        self.peripherals = []
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
        case .PoweredOff:
            self.clearDevices()
        case .Unauthorized:
            // ios device doesn't support ble
            break
        case .Unknown:
            break
        case .PoweredOn:
            self.startScaning()
        case .Resetting:
            self.clearDevices()
        case .Unsupported:
            break
        }
    }

    
    @nonobjc
    // callback function, Invoked when the central manager discovers a peripheral while scanning.
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject: AnyObject]!,
        RSSI: NSNumber!) {
            if peripheral == nil || peripheral.name == nil || peripheral.name == "" {
                return
            }
            // RSSI test distance
//            if RSSI.intValue < -60 {
//                println(RSSI)
//                return
//            }
            if self.peripheralBLE == nil || self.peripheralBLE?.state == CBPeripheralState.Disconnected {
                NSLog("Discovered nearby peripheral: %@ (RSSI: %@)", peripheral.name!, RSSI)
                print(peripheral)
                peripherals.append(peripheral)
                print(peripherals.map({$0.name}))
                return
//                self.peripheralBLE = peripheral
//                
//                self.bleService = nil
//                central.connectPeripheral(peripheral, options: nil)
            }
    }
    // Invoked when the central manager connnected a peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        if  peripheral == nil {
            return
        }
        if peripheral == self.peripheralBLE {
            NSLog("Connected to nearby peripheral: %@", peripheral.name!)
            self.bleService = BTService(initWithPeripheral: peripheral)
        }
        // Stop scaning for new device
        central.stopScan()
    }
    
    // failed to connect peripheral
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        NSLog("Failed to connect to (Peripheral: %@)", peripheral)
        clearDevices()
    }
    // Invoked when the central manager disconnected from a peripheral
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        if peripheral == nil {
            return
        }
        if peripheral == self.peripheralBLE {
            self.clearDevices()
            NSLog("Disconnected from nearby peripheral: %@", peripheral.name!)
        }
        self.startScaning()
    }
}