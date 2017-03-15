//: ## The original prototype.
//:
//: This is the original prototype (Full Source Code) of the mBot-controlling playground.

import Foundation
import CoreBluetooth
import UIKit

// MARK: - Extension for CBUUID
extension CBUUID {
    //mBot services
    @nonobjc static let transDataService = CBUUID(string:"FFF0")
    @nonobjc static let transDataDualService = CBUUID(string:"FFE1")
    
    //Service characteristics
    @nonobjc static let transDataCharateristic = CBUUID(string:"FFF1")
    @nonobjc static let transDataDualCharateristic = CBUUID(string:"FFE3")
    @nonobjc static let notifyDataCharateristic = CBUUID(string:"FFF4")
    @nonobjc static let notifyDataDualCharateristic = CBUUID(string:"FFE2")
}


// MARK: - Connection protocol

/// A representation for (bluetooth or 2.4G) device associated with a mBot
public class Device {
    /// The name of the robot
    public var name = ""
    /// the distance from the robot to the iOS/OSX device
    public var distance:Float = 0.0
}

/**
 *  The protocol for a (Bluetooth or 2.4G) Connection
 */
public protocol Connection {
    
    /// Callback when a device is connected
    var onConnect: (() -> Void)? { get set }
    
    /// Callback when a device is disconnected
    var onDisconnect: (() -> Void)? { get set }
    
    /// Callback when the available device list is changed
    /// (Maybe new device is discovered or an old one disappeared)
    var onAvailableDevicesChanged: (([Device]) -> Void)? { get set }
    
    /// Callback when the connect received data
    var onReceive: ((Data) -> Void)? { get set }
    
    /**
     start discovering devices
     */
    func startDiscovery()
    
    /**
     stop discovering devices
     */
    func stopDiscovery()
    
    // conenct a device, and get notified when connected
    func connect(device: Device)
    
    // disconnect from a device, and get notified when disconnected
    func disconnect()
    
    /**
     send data through the connection
     
     - parameter data: the data to be sent
     */
    func send(data: Data)
    
}


// MARK: - BluetoothConnection

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

// MARK: - MakeblockRobot

/// The representation of the value returned from a mBot sensor
public class SensorValue {
    var numberValue: NSNumber?
    var stringValue: String?
    
    public var intValue: Int {
        get {
            if let intVal: Int = numberValue?.intValue {
                return intVal
            }
            else{
                return 0
            }
        }
    }
    
    public var floatValue: Float {
        get{
            if let floatVal: Float = numberValue?.floatValue {
                return floatVal
            }
            else{
                return 0
            }
        }
    }
    
    init(intValue: Int) {
        numberValue = intValue as NSNumber?
    }
    
    init(floatValue: Float) {
        numberValue = floatValue as NSNumber?
    }
    
    init(string: String){
        stringValue = string
    }
}

/// The representation of a request sent to read a sensor value
public class ReadSensorRequest {
    let onRead: (SensorValue) -> Void
    var requestDate: NSDate
    
    init(callback: @escaping (SensorValue) -> Void) {
        onRead = callback
        requestDate = NSDate()
    }
    
    func isExpired() -> Bool {
        return false;
    }
    
    func refresh() {
        requestDate = NSDate()
    }
}


public class MakeblockRobot {
    /// an enum of electronic devices (sensors, motors, etc.)
    public enum DeviceID: UInt8 {
        case DCMotorMove = 0x05
        case DCMotor = 0x0a
        case RGBLED = 0x08
        case Buzzer = 0x22
        case UltrasonicSensor = 0x01
        case LightnessSensor = 0x03
        case LineFollowerSensor = 0x11
    }
    
    // makeblock protocol constants
    let prefixA: UInt8 = 0xff
    let prefixB: UInt8 = 0x55
    let suffixA: UInt8 = 0x0d
    let suffixB: UInt8 = 0x0a
    
    enum ReceiveStateMachineStates {
        case PrefixA, PrefixB, Index, DataType, Payload, SuffixA, SuffixB
    }
    enum ReceiveDataTypes: UInt8 {
        case SingleByte = 1, Float = 2, Short = 3, String = 4, Double = 5, Long = 6
    }
    var receiveSMStatus: ReceiveStateMachineStates = .PrefixA
    let expecetedPayloadCounts: [ReceiveDataTypes: UInt8] = [.SingleByte: 1, .Float: 4, .Short: 2, .Double: 4, .Long: 4]
    var remainingPayloadLength: UInt8 = 0
    var receiveDataType: ReceiveDataTypes = .SingleByte
    var receivedPayloads: [UInt8] = []
    
    
    //read sensor value
    static let mininalReadingIndex: UInt8 = 2
    static let maximumReadingIndex: UInt8 = 254
    static let writingIndex: UInt8 = 1
    var currentIndex = mininalReadingIndex
    
    // the user of MakeblockRobot instances may attach one additional receive data callback.
    var onReceiveData: ((Data) -> Void)?
    var readSensorRequests: [UInt8: ReadSensorRequest] = [:]
    var receiveIndex: UInt8 = 0
    
    var connection: Connection
    
    public init(connection: Connection){
        self.connection = connection
        self.connection.onReceive = self.onReceive
    }
    
    /**
     Send a message through the Connection
     
     - parameter deviceID:     which device (motors, snesors etc.)
     - parameter arrayOfBytes: an UInt8 array of additional bytes to send
     - parameter callback:     if set, it will send a read sensor request and callback when it receives a sensor value
     */
    public func sendMessage(deviceID: DeviceID, arrayOfBytes: [UInt8], callback: ((SensorValue) -> Void)? = nil){
        let metaDataLength: UInt8 = 3
        let messageLength: UInt8 = metaDataLength + UInt8(arrayOfBytes.count)
        let readWriteByte: UInt8 = callback != nil ? 1 : 2
        var index = MakeblockRobot.writingIndex
        if let cb = callback {
            index = currentIndex
            currentIndex = currentIndex + 1
            if currentIndex > MakeblockRobot.maximumReadingIndex {
                currentIndex = MakeblockRobot.mininalReadingIndex
            }
            
            // register callback to read sensor callback list
            readSensorRequests[index] = ReadSensorRequest(callback: cb)
        }
        var finishedBytes: [UInt8] = [prefixA, prefixB, messageLength, index, readWriteByte, deviceID.rawValue]
        finishedBytes.append(contentsOf: arrayOfBytes)
        connection.send(data: Data(bytes: finishedBytes))
    }
    
    /// Makeblock's returning data format is like:
    ///     Prefix... | Index | Data Type           | Data Bytes ................ | Suffix
    ///     0xff  0x55  0x??    1: single byte          eg. 0x01                    0x0d  0x0a
    ///                         2: float (4 bytes)          0x03 0x01 0x01 0x0b
    ///                         3: short (2 bytes)          0x03 0x01
    ///                         4: String (2 bytes)     first byte is the string length
    ///                         5: double (4 bytes)          0x0d 0x0a 0x01 0x0b
    ///                         6: long (4 bytes)            unused
    ///
    /// A state machine is used to parse the returning data.
    /// for writing commands, will receive FF 55 0D 0A, and since 0x0a is not a data type,
    /// this will result in a parse failure and be ignored.
    func onReceive(data: Data) {
        var receivedBytes = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &receivedBytes, count: data.count)
        for byte in receivedBytes {
            switch receiveSMStatus {
            case .PrefixA:
                if byte == prefixA {
                    receiveSMStatus = .PrefixB
                }
            case .PrefixB:
                if byte == prefixB {
                    receiveSMStatus = .Index
                }
                else{
                    receiveSMStatus = .PrefixA  // parse failure, resetting
                }
            case .Index:
                receiveIndex = byte
                receiveSMStatus = .DataType
            case .DataType:
                if let dataType = ReceiveDataTypes(rawValue: byte) {
                    receiveDataType = dataType
                    receiveSMStatus = .Payload
                    receivedPayloads = []   // prepare to receive payloads
                    if dataType != .String {
                        // use a table to determine the payload length
                        remainingPayloadLength = expecetedPayloadCounts[dataType]!
                    }
                    else {
                        // for string type, payload length is specified in next byte;
                        // but here init as 1, for 0 will result in a fall through
                        // of the payload reading phase
                        remainingPayloadLength = 1
                    }
                }
                else{
                    receiveSMStatus = .PrefixA // parse failure, resetting
                }
            case .Payload:
                // in String type, the first character is for length
                if remainingPayloadLength > 0 {
                    if receiveDataType == .String {
                        if receivedPayloads.count == 0 {
                            remainingPayloadLength = byte
                        }
                        else{
                            receivedPayloads.append(byte)
                            remainingPayloadLength = remainingPayloadLength - 1
                        }
                    }
                    else{   // if data type is not String
                        receivedPayloads.append(byte)
                        remainingPayloadLength = remainingPayloadLength - 1
                    }
                }
                if remainingPayloadLength <= 0 {
                    receiveSMStatus = .SuffixA
                }
            case .SuffixA:
                if byte == suffixA {
                    receiveSMStatus = .SuffixB
                }
                else{
                    receiveSMStatus = .PrefixA
                }
            case .SuffixB:
                // parse received bytes, according to their respected types
                if let request = readSensorRequests[receiveIndex] {
                    switch receiveDataType {
                    case .SingleByte:
                        request.onRead(SensorValue(intValue: Int(receivedPayloads[0])))
                    case .Float:
                        fallthrough
                    case .Double:
                        // in Makeblock's MCU definition, Double is the same as Float;
                        // Then convert 4 bytes to a float value.
                        var f: Float = 0.0
                        memcpy(&f, receivedPayloads, 4)
                        request.onRead(SensorValue(floatValue: f))
                        receivedPayloads = []
                    case .Short:
                        let value: Int = (Int(receivedPayloads[1]) << 8) | Int(receivedPayloads[0])
                        request.onRead(SensorValue(intValue: Int(value)))
                    case .Long:
                        let value: Int = (Int(receivedPayloads[3]) << 24) | (Int(receivedPayloads[2]) << 16) |
                            (Int(receivedPayloads[1]) << 8) | Int(receivedPayloads[0])
                        request.onRead(SensorValue(intValue: Int(value)))
                    case .String:
                        let resultString = NSString(bytes: receivedPayloads, length: receivedPayloads.count,
                                                    encoding:String.Encoding.utf8.rawValue) as! String
                        request.onRead(SensorValue(string: resultString))
                    }
                    // the reading request is fulfilled. Remove from the pending request list.
                    readSensorRequests.removeValue(forKey: receiveIndex)
                }
                receiveSMStatus = .PrefixA
            }
        }
        // if there are additional callbacks, run them.
        if let callback = onReceiveData {
            callback(data)
        }
    }
}


// MARK: - MBot

public class MBot: MakeblockRobot{
    
    public override init(connection: Connection){
        super.init(connection: connection)
    }
}

extension MBot {
    public func nearest() {
        connection.startDiscovery()
        
        if let aConnection = connection as? BluetoothConnection{
            aConnection.onDeviceRSSIChanged = {device, rssi in
                if aConnection.state == BluetoothConnectionState.connected{
                    return
                }
                let rssiConnecting = 38.0
                if fabs(Double(rssi)) < rssiConnecting{
                    aConnection.connect(device: device)
                }
            }
        }
    }
}

extension MBot {
    /// which LED Light to set when sending setRGBLED commands
    public enum RGBLEDPosition: UInt8 {
        case all = 0
        case left = 1
        case right = 2
    }
    
    /// an enum of available ports of mBot controller board
    public enum MBotPorts: UInt8 {
        case RGBLED = 7, Port3 = 3, Port4 = 4, Port1 = 1, Port2 = 2, M1 = 0x09, M2 = 0x0a, LightnessSensor = 0x06
    }
    
    /// an enum of music note pitch -> frequencies
    public enum MusicNotePitch: Int {
        case C2=65, D2=73, E2=82, F2=87, G2=98, A2=110, B2=123, C3=131, D3=147, E3=165, F3=175, G3=196, A3=220, B3=247, C4=262, D4=294, E4=330, F4=349, G4=392, A4=440, B4=494, C5=523, D5=587, E5=658, F5=698, G5=784, A5=880, B5=988, C6=1047, D6=1175, E6=1319, F6=1397, G6=1568, A6=1760, B6=1976, C7=2093, D7=2349, E7=2637, F7=2794, G7=3136, A7=3520, B7=3951, C8=4186
    }
    
    /// an enum of music note duration -> milliseconds
    public enum MusicNoteDuration: Int {
        case full=1000, half=500, quarter=250, eighth=125, sixteenth=62
    }
    
    /// an enum of line-follower sensor status.
    public enum LineFollowerSensorStatus: Float {
        case LeftBlackRightBlack=0.0, LeftBlackRightWhite=1.0, LeftWhiteRightBlack=2.0, LeftWhiteRightWhite=3.0
    }
    
    /**
     Set the speed of both motors of the mBot
     
     - parameter leftMotor:  speed of the left motor, -255~255
     - parameter rightMotor: speed of the right motor, -255~255
     */
    public func setMotors(leftMotor: Int, rightMotor: Int) {
        let (leftLow, leftHigh) = IntToUInt8Bytes(-leftMotor)
        let (rightLow, rightHigh) = IntToUInt8Bytes(rightMotor)
        sendMessage(deviceID: .DCMotorMove, arrayOfBytes: [leftLow, leftHigh, rightLow, rightHigh])
    }
    
    /**
     Set the speed of a single motor of a mBot
     
     - parameter port:  which port the motor is connect to. .M1 or .M2
     - parameter speed: the speed of the motor -255~255
     */
    public func setMotor(port: MBotPorts, speed: Int){
        let (low, high) = IntToUInt8Bytes(speed)
        sendMessage(deviceID: .DCMotor, arrayOfBytes: [port.rawValue, low, high])
    }
    
    /**
     Tell the mBot to move forward
     
     - parameter speed: the speed of moving. -255~255
     */
    public func moveForward(speed: Int){
        setMotors(leftMotor: speed, rightMotor: speed)
    }
    
    /**
     Tell the mBot to move backward
     
     - parameter speed: the speed of moving. -255~255
     */
    public func moveBackward(speed: Int){
        setMotors(leftMotor:-speed, rightMotor: -speed)
    }
    
    /**
     Tell the mBot to turn left
     
     - parameter speed: the speed of moving. -255~255
     */
    public func turnLeft(speed: Int){
        setMotors(leftMotor: -speed, rightMotor: speed)
    }
    
    /**
     Tell the mBot to turn right
     
     - parameter speed: the speed of moving. -255~255
     */
    public func turnRight(speed: Int){
        setMotors(leftMotor: speed, rightMotor: -speed)
    }
    
    /**
     Tell the mBot to stop moving
     */
    public func stopMoving(){
        setMotors(leftMotor: 0, rightMotor: 0)
    }
    
    /**
     Set the color of on-board LEDs of the mBot
     
     - parameter position: which LED. Can be .left, .right or .all
     - parameter red:      red value (0~255)
     - parameter green:    green value (0~255)
     - parameter blue:     blue value (0~255)
     */
    public func setRGBLED(position: RGBLEDPosition, red: Int, green: Int, blue: Int){
        sendMessage(deviceID: .RGBLED, arrayOfBytes: [MBotPorts.RGBLED.rawValue, 0x02, position.rawValue,
                                                      UInt8(red), UInt8(green), UInt8(blue)])
    }
    
    /**
     Set the color of on-board LEDs of the mBot
     
     - parameter position: which LED. Can be .left, .right or .all
     - parameter red:      red value (0~255)
     - parameter green:    green value (0~255)
     - parameter blue:     blue value (0~255)
     */
    public func setRGBLED(position: RGBLEDPosition,color: UIColor){
        let brightness:CGFloat = 1.0
        let components = color.cgColor.components
        let red = components![0]*255*brightness
        let green = components![1]*255*brightness
        let blue = components![2]*255*brightness
        sendMessage(deviceID: .RGBLED, arrayOfBytes: [MBotPorts.RGBLED.rawValue, 0x02, position.rawValue,
                                                      UInt8(red), UInt8(green), UInt8(blue)])
    }
    
    /**
     Use the buzzer to play a musical note
     
     - parameter pitch:    pitch value eg. .C4 .E4
     - parameter duration: duration. Could be .full, .half, .quarter, .eighth, or .sixteenth
     */
    public func setBuzzer(pitch: MusicNotePitch, duration: MusicNoteDuration) {
        let (pitchLow, pitchHigh) = IntToUInt8Bytes(pitch.rawValue)
        let (durationLow, durationHigh) = IntToUInt8Bytes(duration.rawValue)
        sendMessage(deviceID: .Buzzer, arrayOfBytes: [pitchLow, pitchHigh, durationLow, durationHigh])
    }
    
    /**
     Read the value of the ultrasoic sensor. and Call the callback when there's value returning
     usage:
     ```
     mbot.getUltrasonicSensorValue() { value in
     print("ultrasonic sensor says \(value)")
     }
     ```
     
     - parameter port:     which port the sensor is connected to. By default .Port3
     - parameter callback: a block of code executed after we have a value. Receive a Float as the argument.
     */
    public func getUltrasonicSensorValue(port: MBotPorts = .Port3, callback: @escaping ((Float) -> Void)) {
        sendMessage(deviceID: .UltrasonicSensor, arrayOfBytes: [port.rawValue]) { value in
            callback(value.floatValue)
        }
    }
    
    /**
     Read the value of the lightness sensor. and Call the callback when there's value returning
     usage:
     ```
     mbot.getLightnessSensorValue() { value in
     print("lightness sensor says \(value)")
     }
     ```
     
     - parameter port:     which port the sensor is connected to. By default .LightnessSensor (on board sensor)
     - parameter callback: a block of code executed after we have a value. Receive a Float as the argument.
     */
    public func getLightnessSensorValue(port: MBotPorts = .LightnessSensor, callback: @escaping ((Float) -> Void)) {
        sendMessage(deviceID: .LightnessSensor, arrayOfBytes: [port.rawValue]) { value in
            callback(value.floatValue)
        }
    }
    
    /**
     Read the value of the line-follower sensor. and Call the callback when there's value returning
     usage:
     ```
     mbot.getLinefollowerSensorValue() { value in
     if(value == .LeftBlackRightBlack) {
     // do things when the line-follower is left-black-right-black
     }
     }
     ```
     
     - parameter port:     which port the sensor is connected to. By default .Port2 (on board sensor)
     - parameter callback: a block of code executed after we have a value. Receive a LineFollowerSensorStatus as the argument.
     */
    public func getLinefollowerSensorValue(port: MBotPorts = .Port2, callback:@escaping ((LineFollowerSensorStatus) -> Void)) {
        sendMessage(deviceID: .LineFollowerSensor, arrayOfBytes: [port.rawValue]) { value in
            callback(LineFollowerSensorStatus.init(rawValue: value.floatValue)!)
        }
    }
    
    func IntToUInt8Bytes(_ value: Int) -> (UInt8, UInt8){
        let lowValue = UInt8(value & 0xff)
        let highValue = UInt8((value >> 8) & 0xff)
        return (lowValue, highValue)
    }
    
    
    /// Handle joystickMoved event
    ///
    /// - Parameters:
    ///   - angle: joystick move angle
    ///   - magnitude: joystick move magnitude
    ///   - targetPoint: joystick thumb target point
    ///   - centerPoint: joystick center point
    ///   - radius: joystick radius
    public func joystickMoved(angle: Double,magnitude: Double,targetPoint:CGPoint,centerPoint:CGPoint,radius:Double) {
        if angle == 0 && magnitude == 0{
            stopMoving()
            return
        }
        
        let maxSpeed = 255.0
        
        let xValue = targetPoint.x - centerPoint.x
        let tolerantXValue = abs(xValue)<10.0 ? 0.0 : Double(xValue)
        let speed = tolerantXValue/radius
        var leftSpeed = 0.0
        var rightSpeed = 0.0
        if xValue > 0 {
            leftSpeed = speed
        }else{
            rightSpeed = -speed
        }
        
        let yValue = targetPoint.y - centerPoint.y
        let tolerantYValue = abs(yValue)<10.0 ? 0.0 : Double(yValue)
        let deltax = -(tolerantYValue)/radius
        leftSpeed += deltax
        rightSpeed += deltax
        
        leftSpeed *= maxSpeed
        rightSpeed *= maxSpeed
        
        setMotors(leftMotor: Int(leftSpeed), rightMotor: Int(rightSpeed))
    }
}


// MARK: - viewController

public enum Message: String {
    case nearmBot = "Near mBot will be automatically connected."
    case connected = "Connected."
    case connecting = "Connecting..."
}

private class ColorWell: UIView {
    let color: UIColor
    var selected = false {
        didSet {
            if selected {
                self.layer.borderWidth = 5
            } else {
                self.layer.borderWidth = 1
            }
        }
    }
    let action: (ColorWell) -> Void
    
    init(color: UIColor, action: @escaping (ColorWell) -> Void) {
        self.color = color
        self.action = action
        
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 25.0
        self.backgroundColor = color
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ColorWell.tapped(_:)))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        action(self)
    }
}

private class FlipImageView : UIImageView {
    public var onImage: UIImage!
    public var offImage: UIImage!
    
    public func flipOn() -> Void {
        image = onImage;
    }
    
    public func flipOff() -> Void {
        image = offImage;
    }
    
    public func setFlip(value:(Bool)) -> Void {
        if value {
            self.flipOn()
        }
        else {
            self.flipOff()
        }
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        offImage = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


public class ContorlViewController: UIViewController {
    private var joystickView: UIView!
    private var joystickBgView: UIImageView!
    private var joystickThumbView: UIImageView!
    private var joystickUpArrowView: FlipImageView!
    private var joystickDownArrowView: FlipImageView!
    private var joystickLeftArrowView: FlipImageView!
    private var joystickRightArrowView: FlipImageView!
    private var colorWellContainer: UIStackView!
    private var hintLabel: UILabel!
    public var defaultHintInfo: String = ""
    
    public var joystickMoved: ((_ angle: Double,_ magnitude: Double,_ targetPoint:CGPoint,_ centerPoint:CGPoint,_ radius:Double) -> Void)?
    public var colorSelected: ((UIColor) -> Void)?
    
    private var selectedWell: ColorWell! {
        didSet {
            if selectedWell.selected {
                return
            }
            
            selectedWell.selected = true
            if let old = oldValue {
                old.selected = false
            }
            colorSelected?(selectedWell.color)
        }
    }
    
    public func setHintInfo(content: String){
        hintLabel.text = content
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        //HintLabel
        hintLabel = UILabel(frame: CGRect(x:10, y:60, width:500, height:30))
        view.addSubview(hintLabel)
        hintLabel.textColor = UIColor.orange
        hintLabel.text = self.defaultHintInfo
        
        let joystickWidthMultiplier:CGFloat = 0.5
        
        //Joystick
        joystickView = UIView()
        view.addSubview(joystickView)
        joystickView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joystickView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:-50).isActive = true
        joystickView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier:joystickWidthMultiplier).isActive = true
        joystickView.heightAnchor.constraint(equalTo: joystickView.widthAnchor).isActive = true
        
        joystickBgView = UIImageView(image: UIImage(named: "joystick-base")!)
        joystickView.addSubview(joystickBgView)
        joystickBgView.translatesAutoresizingMaskIntoConstraints = false
        joystickBgView.centerXAnchor.constraint(equalTo: joystickView.centerXAnchor).isActive = true
        joystickBgView.centerYAnchor.constraint(equalTo: joystickView.centerYAnchor).isActive = true
        joystickBgView.leftAnchor.constraint(equalTo: joystickView.leftAnchor).isActive = true
        joystickBgView.topAnchor.constraint(equalTo: joystickView.topAnchor).isActive = true
        
        joystickUpArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-u")!)
        joystickUpArrowView.onImage = UIImage(named: "joystick-highlighter-u-a")!
        joystickUpArrowView.contentMode = .scaleAspectFit
        joystickView.addSubview(joystickUpArrowView)
        joystickUpArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 0.2, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1*17.0/21.0, constant: 0))
        
        joystickDownArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-d")!)
        joystickDownArrowView.onImage = UIImage(named: "joystick-highlighter-d-a")!
        joystickView.addSubview(joystickDownArrowView)
        joystickDownArrowView.contentMode = .scaleAspectFit
        joystickDownArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 1.77, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1*17.0/21.0, constant: 0))
        
        
        joystickLeftArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-l")!)
        joystickLeftArrowView.onImage = UIImage(named: "joystick-highlighter-l-a")!
        joystickLeftArrowView.contentMode = .scaleAspectFit
        joystickView.addSubview(joystickLeftArrowView)
        joystickLeftArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 0.23, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1*21.0/17.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1, constant: 0))
        
        joystickRightArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-r")!)
        joystickRightArrowView.onImage = UIImage(named: "joystick-highlighter-r-a")!
        joystickRightArrowView.contentMode = .scaleAspectFit
        joystickView.addSubview(joystickRightArrowView)
        joystickRightArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 1.77, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1*21.0/17.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1, constant: 0))
        
        joystickThumbView = UIImageView(image: UIImage(named: "joystick-thumb")!)
        joystickView.addSubview(joystickThumbView)
        joystickThumbView.translatesAutoresizingMaskIntoConstraints = false
        joystickThumbView.centerXAnchor.constraint(equalTo: joystickView.centerXAnchor).isActive = true
        joystickThumbView.centerYAnchor.constraint(equalTo: joystickView.centerYAnchor).isActive = true
        joystickThumbView.widthAnchor.constraint(equalTo: joystickView.widthAnchor, multiplier:0.333).isActive = true
        joystickThumbView.heightAnchor.constraint(equalTo: joystickThumbView.widthAnchor, multiplier:1.157).isActive = true
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didTap(_:)))
        joystickView.addGestureRecognizer(gestureRecognizer)
        
        
        //ColorWell
        colorWellContainer = UIStackView(arrangedSubviews: [])
        colorWellContainer.translatesAutoresizingMaskIntoConstraints = false
        colorWellContainer.distribution = .equalCentering
        
        let colors = [#colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
        for color in colors {
            let well = ColorWell(color: color, action: { (selectedWell) in
                self.selectedWell = selectedWell
            })
            well.translatesAutoresizingMaskIntoConstraints = false
            
            colorWellContainer.addArrangedSubview(well)
        }
        
        colorWellContainer.backgroundColor = UIColor.clear
        view.addSubview(colorWellContainer)
        colorWellContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        view.trailingAnchor.constraint(equalTo: colorWellContainer.trailingAnchor, constant: 20).isActive = true
        view.bottomAnchor.constraint(equalTo: colorWellContainer.bottomAnchor, constant: 100).isActive = true
        colorWellContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc private func didTap(_ gestureRecognizer: UIPinchGestureRecognizer) {
        var targetPoint = gestureRecognizer.location(in: joystickBgView)
        let centerPoint = joystickBgView.center
        let thumbDistance = distance(point1: targetPoint, point2: centerPoint)
        
        let joystickThumbMaxDragRadius = joystickThumbView.bounds.height*0.6
        
        if thumbDistance > joystickThumbMaxDragRadius {
            let x = centerPoint.x + (targetPoint.x-centerPoint.x)/thumbDistance*joystickThumbMaxDragRadius
            let y = centerPoint.y + (targetPoint.y-centerPoint.y)/thumbDistance*joystickThumbMaxDragRadius
            targetPoint = CGPoint(x: x, y: y)
        }
        
        if gestureRecognizer.state == .ended {
            joystickThumbView.image = UIImage(named: "joystick-thumb-shadowed")
            joystickThumbView.center = centerPoint
            self.highlightArrow(x: 0, y: 0)
            //stop
            joystickMoved?(Double(0), Double(0),targetPoint,centerPoint,Double(joystickThumbMaxDragRadius))
            
        }else {
            if gestureRecognizer.state == .began{
                joystickThumbView.image = UIImage(named: "joystick-thumb")
            }
            joystickThumbView.center = targetPoint;
            self.highlightArrow(x: targetPoint.x - centerPoint.x, y: targetPoint.y - centerPoint.y)
            judgeDirection(targetPoint: targetPoint, centerPoint: centerPoint, radius: joystickThumbMaxDragRadius)
        }
    }
    
    private func judgeDirection(targetPoint:CGPoint , centerPoint:CGPoint , radius:CGFloat) {
        let angle = Double(atan2(centerPoint.y-targetPoint.y, centerPoint.x - targetPoint.x) * 180) / M_PI
        let dis = distance(point1: targetPoint, point2: centerPoint)
        let magnitude = dis / radius
        joystickMoved?(angle,Double(magnitude),targetPoint, centerPoint,Double(radius))
    }
    
    private func distance(point1:CGPoint, point2:CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt((dx*dx + dy*dy))
    }
    
    private func highlightArrow(x:(CGFloat), y:(CGFloat)) -> Void {
        let highlightTolerance: CGFloat = 10.0
        joystickUpArrowView.setFlip(value: !(y < -highlightTolerance ? false : true))
        joystickDownArrowView.setFlip(value: !(y > highlightTolerance ? false : true))
        joystickRightArrowView.setFlip(value: !(x > highlightTolerance ? false : true))
        joystickLeftArrowView.setFlip(value: !(x < -highlightTolerance ? false : true))
    }
}

// MARK: - Client

let connection = BluetoothConnection()
let mBot: MBot = MBot(connection:connection)

mBot.nearest()

let viewController = ContorlViewController()

viewController.defaultHintInfo = Message.nearmBot.rawValue

connection.onStateChanged = { state in
    if state == BluetoothConnectionState.idle{
        viewController.setHintInfo(content:Message.nearmBot.rawValue)
    }
    else if state == BluetoothConnectionState.connected{
        viewController.setHintInfo(content:Message.connected.rawValue)
    }
    else if state == BluetoothConnectionState.connecting{
        viewController.setHintInfo(content:Message.connecting.rawValue)
    }
}

viewController.joystickMoved = {angle,magnitude,targetPoint,centerPoint,radius in
    mBot.joystickMoved(angle: angle, magnitude: magnitude, targetPoint: targetPoint, centerPoint: centerPoint, radius: radius)
}

viewController.colorSelected = {color in
    mBot.setRGBLED(position: .all, color: color)
}

import PlaygroundSupport

PlaygroundPage.current.liveView = viewController

//#-end-editable-code
