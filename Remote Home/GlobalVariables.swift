//
//  GlobalVariables.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 28/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation


class GlobalVariables {
    static let sharedInstance = GlobalVariables()
    var gameScore:String = ""
    var isChangingDeviceName:Bool = false
    var user:UserVO = UserVO()
    var device:DeviceVO = DeviceVO()
    var actualDevice:DeviceVO = DeviceVO()
    var initialDate:Date = Date.init()
    var endDate:Date = Date.init()
    var shouldReloadGraphics:Bool = false
    
}
