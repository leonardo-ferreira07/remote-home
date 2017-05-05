//
//  UserVO.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 29/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

class UserVO {
    var userUID:String = ""
    var userName:String = ""
    var userEmail:String = ""
    var userPassword:String = ""
    var userPhone:String = ""
    var userAllowsAllNotification:Bool = false
    var devicesList:NSMutableArray = []
    var actualDeviceID:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var devicesListLocation:NSMutableArray = []
    var maximumCost:Double = 0.0
    var energyCost:Double = 0.0
}
