import PlaygroundSupport
import Foundation
import UIKit

let viewController = BasicControlViewController()
public var execiseCode:(()-> Void)?
public var execiseWithViewController:((BasicControlViewController)-> Void)?
public var cmd:BasicCommands!

public func runWithCommands() {
    viewController.listenStartButtonClicked = { sender in
        cmd = BasicCommands(robot: viewController.mBot)
        
        execiseCode?()
        execiseWithViewController?(viewController)
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
    cmd.beepDo()
}

public func beepMi() {
    cmd.beepMi()
}

public func beepSol() {
    cmd.beepSol()
}

public func subscribeUltrasonicSensor(callback:@escaping (Float)->Void) {
    cmd.subscribeUltrasonicSensor { (value) in
        callback(value)
    }
}

public func subscribeLightnessSensor(callback:@escaping (Float)->Void) {
    cmd.subscribeLightnessSensor { (value) in
        callback(value)
    }
}

public func getDistance(callback:@escaping (Float)->Void) {
    cmd.getDistance(callback: callback)
}

public func getLightStrength(callback:@escaping (Float)->Void) {
    cmd.getLightStrength(callback: callback)
}
