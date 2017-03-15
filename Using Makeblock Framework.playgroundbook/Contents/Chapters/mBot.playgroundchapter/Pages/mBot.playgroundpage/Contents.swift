//: ## Control a mBot device with your iPad!
//:
//: When you hit the "Run My Code" button on this page you will see a joystick-like
//: control that lets you drive a mBot robot around your room.
//: But that's not all, [on the next page](@next) you can write Swift code to control
//: your mBot device directly.
//:
//: For more information on programming the mBot robots, you can see the documentation at
//: [https://github.com/Makeblock-official/Makeblock-Swift](https://github.com/Makeblock-official/Makeblock-Swift).  
//#-editable-code

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
