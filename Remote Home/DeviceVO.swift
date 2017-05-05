//
//  DeviceVO.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 29/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

class DeviceVO {
    var deviceUID:String = ""
    var deviceName:String = ""
    var deviceStatus:Bool = false
    var deviceOperation:String = ""
    var allowsNotification:Bool = false
    var active:Bool = false
    var devicesList:NSMutableArray = []
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var radius:Double = 0.0
    var devicesListLocation:NSMutableArray = []
    var deviceType:String = ""
}
