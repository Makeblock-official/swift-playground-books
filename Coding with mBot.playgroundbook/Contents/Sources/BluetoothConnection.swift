//
//  BluetoothConnection.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/19.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import Foundation
import CoreBluetooth

/// An bluetooth device
public class BluetoothDevice: Device{
    var peripheral: CBPeripheral
    var rssi: NSNumber? {
        didSet {
            self.distance = distanceByRSSI()
        }
    }
    
    func distanceByRSSI() -> Float{
        if let rssi = rssi {
            return powf(10.0,((abs(rssi.floatValue)-50.0)/50.0))*0.7
        }
        return -1.0
    }
    
    /**
     Create a device using a CBPeripheral
     Normally you don't need to init a BluetoothDevice by yourself
     
     - parameter peri: the peripheral instance
     
     - returns: nil
     */
    public init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}

public enum BluetoothConnectionState : Int {
    case idle
    case connecting
    case connected
}

/// The bluetooth connection
public class BluetoothConnection: NSObject, Connection, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private lazy var central: CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    private var discoveredDevices: [UUID: BluetoothDevice] = [:]
    var activePeripheral: CBPeripheral?
    var state: BluetoothConnectionState = .idle {
        didSet {
            self.onStateChanged?(state)
        }
    }
    var isDual = false
    var notifyReady = false
    private var transDataCharateristic: CBCharacteristic?
    
    /// the maximum length of the package that can be send
    let notifyMTU = 20 // maximum 20 bytes in a single ble package
    
    public var onConnect: (() -> Void)?
    public var onDisconnect: (() -> Void)?
    public var onAvailableDevicesChanged: (([Device]) -> Void)?
    public var onReceive: ((Data) -> Void)?
    public var onDeviceRSSIChanged: ((Device,NSNumber) -> Void)?
    public var onStateChanged: ((_ state: BluetoothConnectionState) -> Void)?
    
    // Connection Methods
    public func startDiscovery() {
        guard central.state == .poweredOn && !central.isScanning else { return }
        
        central.scanForPeripherals(withServices:nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    public func stopDiscovery() {
        guard central.isScanning else { return }
        
        central.stopScan()
    }
    
    public func connect(device: Device) {
        if state == .connecting || state == .connected {
            return
        }
        
        if let bluetoothDevice = device as? BluetoothDevice {
            state = .connecting;
            
            if !discoveredDevices.keys.contains(bluetoothDevice.peripheral.identifier){
                fatalError("Asked to connect to a peripheral which was not discovered or to which a connection was previously established")
            }
            
            self.central.connect(bluetoothDevice.peripheral, options: nil)
            
            stopDiscovery()
        }
    }

    public func disconnect() {
        if let peripheral = activePeripheral {
            self.central.cancelPeripheralConnection(peripheral)
            activePeripheral = nil
            state = .idle;
            resetDiscovery()
        }
    }
    
    public func send(data: Data) {
        if let peripheral = activePeripheral {
            if peripheral.state == .connected{
                if let characteristic = transDataCharateristic {
                    var sendIndex = 0
                    while true {
                        var amountToSend = data.count - sendIndex
                        if amountToSend > notifyMTU {
                            amountToSend = notifyMTU
                        }
                        if amountToSend <= 0 {
                            return;
                        }
                        let dataChunk = data.subdata(in:sendIndex..<sendIndex+amountToSend)
                        peripheral.writeValue(dataChunk, for:characteristic, type: .withoutResponse)
                        sendIndex += amountToSend
                    }
                }
            }
        }
    }
    
    /// Stop and start scanning Bluetooth devices
    func resetDiscovery() {
        stopDiscovery()
        startDiscovery()
    }
    
    
    // CoreBluetooth Methods
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startDiscovery()
        case .poweredOff:
            stopDiscovery()
        case .resetting:
            break
        case .unauthorized, .unknown, .unsupported:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        
        if let device = discoveredDevices[peripheral.identifier] {
            //Update rssi
            device.rssi = rssi
            onDeviceRSSIChanged?(device,rssi)
        }
        else{
            if let name = peripheral.name {
                if !name.hasPrefix("Makeblock") {
                    return
                }
                
                let device = BluetoothDevice(peripheral:peripheral)
                device.rssi = rssi
                discoveredDevices[peripheral.identifier] = device
                
                var deviceList:[BluetoothDevice] = []
                for discoveredDevice in discoveredDevices.values {
                    deviceList.append(discoveredDevice)
                }
                if deviceList.count > 1{
                    deviceList.sort() { $0.distanceByRSSI() < $1.distanceByRSSI() }
                }
                onAvailableDevicesChanged?(deviceList)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        state = .idle;
        print("failed to connect peripheral")
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnect()
        onDisconnect?()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        activePeripheral = peripheral
        activePeripheral?.delegate = self
        activePeripheral?.discoverServices([.transDataService, .transDataDualService])
    }
    
    //CBPeripheralDelegate Methods
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            switch service.uuid {
            case CBUUID.transDataService:
                peripheral.discoverCharacteristics([.transDataCharateristic, .transDataDualCharateristic, .notifyDataCharateristic, .notifyDataDualCharateristic], for: service)
            case CBUUID.transDataDualService:
                isDual = true
                peripheral.discoverCharacteristics([.transDataCharateristic, .transDataDualCharateristic, .notifyDataCharateristic, .notifyDataDualCharateristic], for: service)
            default:
                // This is a service we don't care about. Ignore it.
                continue
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            switch characteristic.uuid {
            //trans data
            case CBUUID.transDataCharateristic,CBUUID.transDataDualCharateristic:
                transDataCharateristic = characteristic
                checkAndNotifyIfConnected()
                
            //notify data
            case CBUUID.notifyDataCharateristic,CBUUID.notifyDataDualCharateristic:
                peripheral .setNotifyValue(true, for: characteristic)
                notifyReady = true
                checkAndNotifyIfConnected()
                
            default:
                // This is a characteristic we don't care about. Ignore it.
                continue
            }
        }
    }
    
   public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }
        
        if (characteristic.uuid.isEqual(CBUUID.notifyDataCharateristic) || characteristic.uuid.isEqual(CBUUID.notifyDataDualCharateristic)){
            if let data = characteristic.value{
                onReceive?(data)
            }
        }
    }
    
    /// If both write characteristic and notify is setup, call "onConnected" callback
    func checkAndNotifyIfConnected() {
        if notifyReady && transDataCharateristic != nil {
            state = .connected;
            onConnect?()
        }
    }
}
