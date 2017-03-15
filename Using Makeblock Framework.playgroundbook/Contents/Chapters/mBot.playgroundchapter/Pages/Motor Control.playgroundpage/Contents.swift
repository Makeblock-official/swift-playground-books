//: [The previous page](@previous) has shown how to control LEDs on the mBot
//:
//:
//: This page uses Swift code to control the mBot motors

//#-editable-code Tap to enter code
import PlaygroundSupport
import Foundation

let connection = BluetoothConnection()
let mBot: MBot = MBot(connection:connection)

mBot.nearest()

let viewController = MotorControlViewController()

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

viewController.listenStartButtonClicked = { sender in
    mBot.moveForward(speed:100)
    Thread.sleep(forTimeInterval: 2)
    mBot.moveBackward(speed:100)
    Thread.sleep(forTimeInterval: 2)
    mBot.turnLeft(speed:100)
    Thread.sleep(forTimeInterval: 2)
    mBot.turnRight(speed:100)
    Thread.sleep(forTimeInterval: 2)
    mBot.stopMoving()
    Thread.sleep(forTimeInterval: 1)
    mBot.setMotors(leftMotor:0, rightMotor:100)
    Thread.sleep(forTimeInterval: 3)
    mBot.stopMoving()
}

PlaygroundPage.current.liveView = viewController
//#-end-editable-code
