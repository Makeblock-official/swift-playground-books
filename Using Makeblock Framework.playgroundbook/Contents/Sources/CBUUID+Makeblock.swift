//
//  CBUUID+Makeblock.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/13.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBUUID {
    //mBot services
    @nonobjc static let transDataService = CBUUID(string:"FFF0")
    @nonobjc static let transDataDualService = CBUUID(string:"FFE1")
    
    //Service characteristics
    @nonobjc static let transDataCharateristic = CBUUID(string:"FFF1")
    @nonobjc static let transDataDualCharateristic = CBUUID(string:"FFE3")
    @nonobjc static let notifyDataCharateristic = CBUUID(string:"FFF4")
    @nonobjc static let notifyDataDualCharateristic = CBUUID(string:"FFE2")
}
