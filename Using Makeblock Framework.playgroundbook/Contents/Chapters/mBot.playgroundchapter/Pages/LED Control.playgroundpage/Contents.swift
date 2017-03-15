//: [On the previous page](@previous), you used a joystick to control a mBot
//: robot by hand.
//:
//: This page uses Swift code to control the mBot LED

//#-editable-code Tap to enter code
import PlaygroundSupport
import Foundation

let connection = BluetoothConnection()
let mBot: MBot = MBot(connection:connection)

//close to connect
mBot.nearest()

let viewController = LEDControlViewController()

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

viewController.listenColorChanged = { color in
    mBot.setRGBLED(position: .all, color:color)
}

PlaygroundPage.current.liveView = viewController
//#-end-editable-code
