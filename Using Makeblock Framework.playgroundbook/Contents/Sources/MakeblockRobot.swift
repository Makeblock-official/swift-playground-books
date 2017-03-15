//
//  MakeblockRobot.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/19.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import Foundation

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
