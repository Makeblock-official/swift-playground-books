import Foundation
import UIKit

public class BasicCommands {
    public var mBot: MBot
    private var ultrasonicCallback: ((Float)->Void)?
    private var lightnessCallback: ((Float)->Void)?
    
    public init(robot:MBot) {
        mBot = robot
    }
    
    public func helloWorld () {
        mBot.setRGBLED(position: .all, red: 0, green:255, blue: 0)
        mBot.turnLeft(speed:200)
        Thread.sleep(forTimeInterval: 0.5)
        mBot.turnRight(speed:200)
        mBot.setRGBLED(position: .all, red: 0, green:0, blue: 255)
        Thread.sleep(forTimeInterval: 0.5)
        mBot.turnLeft(speed:200)
        Thread.sleep(forTimeInterval: 0.5)
        mBot.turnRight(speed:200)
        Thread.sleep(forTimeInterval: 0.5)
        mBot.stopMoving()
        mBot.setRGBLED(position: .all, red:0, green:0, blue:0)
    }
    
    public func forward () {
        mBot.moveForward(speed:200)
        Thread.sleep(forTimeInterval: 1)
        mBot.stopMoving()
    }
    
    public func back () {
        mBot.moveBackward(speed:200)
        Thread.sleep(forTimeInterval: 1)
        mBot.stopMoving()
    }
    
    public func left () {
        mBot.turnLeft(speed:200)
        Thread.sleep(forTimeInterval: 1)
        mBot.stopMoving()
    }
    
    public func right () {
        mBot.turnRight(speed:200)
        Thread.sleep(forTimeInterval: 1)
        mBot.stopMoving()
    }
    
    let WaitLengthForRGBLED = 0.5
    public func setRGBLED(position:MBot.RGBLEDPosition, color:UIColor) {
        mBot.setRGBLED(position:position, color:color)
        Thread.sleep(forTimeInterval: WaitLengthForRGBLED)
    }
    
    public func beepDo() {
        mBot.setBuzzer(pitch:.C5, duration: .quarter)
        Thread.sleep(forTimeInterval: 1)
    }
    
    public func beepMi() {
        mBot.setBuzzer(pitch:.E5, duration: .quarter)
        Thread.sleep(forTimeInterval: 1)
    }
    
    public func beepSol() {
        mBot.setBuzzer(pitch:.G5, duration: .quarter)
        Thread.sleep(forTimeInterval: 1)
    }
    
    public func subscribeUltrasonicSensor(callback:@escaping (Float)->Void) {
        ultrasonicCallback = callback
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] (timer) in
            self?.mBot.getUltrasonicSensorValue { (value) in
                self?.ultrasonicCallback!(value)
            }
        }
    }
    
    public func subscribeLightnessSensor(callback:@escaping (Float)->Void) {
        lightnessCallback = callback
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] (timer) in
            self?.mBot.getLightnessSensorValue { (value) in
                self?.lightnessCallback!(value)
            }
        }
    }
    
    public func getDistance(callback:@escaping (Float)->Void) {
        mBot.getUltrasonicSensorValue { (value) in
            callback(value)
        }
    }
    
    public func getLightStrength(callback:@escaping (Float)->Void) {
        mBot.getLightnessSensorValue { (value) in
            callback(value)
        }
    }
}
