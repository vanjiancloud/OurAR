//
//  CloudARExtension.swift
//  OurAR
//
//  Created by lee on 2023/7/7.
//

import Foundation
import CloudAR
import UIKit

extension car_UserInfo
{
    static var name: String = ""
    static var imgUrl: String = ""
    static var threeDURL: String = "" //threeD画面流的url
    static var tokenData: String = ""
}

extension car_URL
{
    static var javaWS: String = "wss://api.OurBim.com:11023"
}


extension car_EngineStatus {
    static let mainToolsInfo: MainToolsInfo = MainToolsInfo()
    static var personview: PersonViewType = .TP //默认第三人称
    static var showTextOfMainTool:Bool = false //是否展示maintool的名称
    
    static var mainToolsOrder: [MainToolType] = [] 
    static var secondToolsOrder: [MainToolType: [SecondToolType]] = [:]
    
    static var lastExitARTime: Int = -1 //上次退出ar场景的时间
}
