//
//  SettingData.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation

enum SettingType: UInt8
{
    case server             = 0
    case address            = 1
}

enum SettingActionType: UInt8
{
    case choice             = 0
    case modify             = 1
    case delete             = 2
    case add                = 3
}
// 单个服务信息
class ServerInfo
{
    var id: String!
    var name: String!
    var javaServer: String!
    var cloudServer: String!
    var javaWS: String!
    init() {
        self.id = String(Date().timeStamp) //用时间戳作为id
    }
    
    func update(name: String,javaServer: String,cloudServer: String,javaWS: String) {
        self.name = name
        self.javaServer = javaServer
        self.cloudServer = cloudServer
        self.javaWS = javaWS
    }
}
// 单个地址信息
class AddressInfo
{
    var id: String!
    var name: String!
    var hostID: String!
    var cloudarIP: String!
    init() {
        self.id = String(Date().timeStamp)
    }
    
    func update(name: String,hostID: String,cloudarIP: String) {
        self.name = name
        self.hostID = hostID
        self.cloudarIP = cloudarIP
    }
}

protocol SettingProtocol
{
    func handleSetting(type: SettingType,action: SettingActionType,info: [String:Any])
}

enum SettingAlertType: UInt8
{
    case delete             = 0
    case modify             = 1
    case add                = 2
}

enum SettingAlertActionType: UInt8
{
    case cancel             = 0
    case confirm            = 1
}

protocol SettingAlertProtocol
{
    func handleAlertAction(alertType: SettingAlertType,actionType: SettingAlertActionType,id: String,info: [String:Any])
}
