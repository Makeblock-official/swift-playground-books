//: [The previous page](@previous) has shown how to control the mBot motors
//:
//:
//: This page uses Swift code to control the mBot buzzer

import PlaygroundSupport
import Foundation

let connection = BluetoothConnection()
let mBot: MBot = MBot(connection:connection)

mBot.nearest()

let viewController = MusicViewController()

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

viewController.listenMusicKeyClicked = { type in
    if type == .Do{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.C5, duration: MBot.MusicNoteDuration.quarter)
    }else if type == .Re{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.D5, duration: MBot.MusicNoteDuration.quarter)
    }else if type == .Mi{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.E5, duration: MBot.MusicNoteDuration.quarter)
    }else if type == .Fa{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.F5, duration: MBot.MusicNoteDuration.quarter)
    }else if type == .Sol{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.G5, duration: MBot.MusicNoteDuration.quarter)
    }else if type == .La{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.A5, duration: MBot.MusicNoteDuration.quarter)
    }else if type == .Si{
        mBot.setBuzzer(pitch: MBot.MusicNotePitch.B5, duration: MBot.MusicNoteDuration.quarter)
    }
}

PlaygroundPage.current.liveView = viewController
