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
    case register       = 1     //注册
    case login          = 2     //登录
    case changePSD      = 3     //找回密码
    case changePhone    = 4     //更换手机
}
