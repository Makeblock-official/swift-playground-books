//
//  MBot+Connection.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/19.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import Foundation

extension MBot {
    public func nearest() {
        connection.startDiscovery()
        
        if let aConnection = connection as? BluetoothConnection{
            aConnection.onDeviceRSSIChanged = {device, rssi in
                if aConnection.state == BluetoothConnectionState.connected{
                    return
                }
                let rssiConnecting = 55.0
                if fabs(Double(rssi)) < rssiConnecting{
                   aConnection.connect(device: device)
                }
            }
        }
    }
}
