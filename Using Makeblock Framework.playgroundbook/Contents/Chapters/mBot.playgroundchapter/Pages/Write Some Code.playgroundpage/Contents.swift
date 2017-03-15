//: Now you can write your own commands to make your mBot device do whatever you want.
//:
//: Use commands like `moveForward(speed:)` and `setRGBLED(position:, red:, green:, blue:)`,`setRGBLED(position:,color:)` to tell your mBot device what to do.

//#-hidden-code
import PlaygroundSupport
import Foundation

let connection = BluetoothConnection()
let mBot: MBot = MBot(connection:connection)

mBot.nearest()

let viewController = WriteSomeCodeViewController()

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

viewController.listenTryButtonClicked = { sender in
//#-end-hidden-code
//#-editable-code Tap to enter code
    //Write your code here!
    mBot.moveForward(speed:100)
    Thread.sleep(forTimeInterval: 2)
    mBot.moveBackward(speed:100)
    Thread.sleep(forTimeInterval: 2)
    mBot.stopMoving()
//#-end-editable-code
    
//#-hidden-code
}
PlaygroundPage.current.liveView = viewController
//#-end-hidden-code
