import PlaygroundSupport
import Foundation
import UIKit

let viewController = BasicControlViewController()
public var execiseCode:(()-> Void)?
public var cmd:BasicCommands!

public func runWithCommands() {
    viewController.listenStartButtonClicked = { sender in
        cmd = BasicCommands(robot: viewController.mBot)
        
        execiseCode!()
    }
    
    PlaygroundPage.current.liveView = viewController
}

public func moveForward() {
    cmd.forward()
}

public func moveBack() {
    cmd.back()
}

public func moveLeft() {
    cmd.left()
}

public func moveRight() {
    cmd.right()
}

public func lightLeft(color:UIColor) {
    cmd.setRGBLED(position: .left, color: color)
}

public func lightRight(color:UIColor) {
    cmd.setRGBLED(position: .right, color: color)
}

public func lightBoth(color:UIColor) {
    cmd.setRGBLED(position: .all, color: color)
}

public func helloWorld() {
    cmd.helloWorld()
}

public func beepDo() {
    // TODO: implement the beeping sound
}

public func beepMi() {
    // TODO: implement the beeping sound
}

public func beepSol() {
    // TODO: implement the beeping sound
}

// subscribing functions are called outside of button-click listeners.
public func subscribeUltrasonicSensor() {
    // TODO: when called, read the sensor every 0.x seconds.
}

public func subscribeLightnessSensor(callback:(Int)->Void) {
    // TODO: when called, read the sensor every 0.x seconds.
}

public func getDistance() {
    // TODO: return the last value of ultrasonic sensor
}

public func getLightStrength() {
    // TODO: return the last value of lightness sensor
}
