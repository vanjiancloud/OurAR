//
//  APIDataStruct.swift
//  OurAR
//
//  Created by lee on 2023/7/20.
//

import Foundation

//测量单位
enum MeasureUnitType : String
{
    case mm         = "mm"
    case cm         = "cm"
    case m          = "m"
    case inch       = "in"
    case ft         = "ft"
}
//测量精度
enum MeasurePrecisionType : String
{
    case noneDecimal        = "0"
    case oneDecimal         = "0.1"
    case twoDecimal         = "0.01"
}
// 验证码类型
enum VerificationType: UInt8
{
    case register       = 0     //注册
    case login          = 1     //登录
    case changePSD      = 2     //找回密码
    case changePhone    = 3     //更换手机
}
