//
//  MBot+Control.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/19.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import Foundation
import UIKit

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
