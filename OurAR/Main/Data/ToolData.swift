//
//  ToolData.swift
//  OurAR
//
//  Created by lee on 2023/7/6.
//

import Foundation
import CloudAR

struct ActorPAKInfo: Hashable,Equatable
{
    var actorId: String = ""
    var pakId: String = ""
    init(actorId: String, pakId: String)
    {
        self.actorId = actorId
        self.pakId = pakId
    }
    
    static func ==(lhs: ActorPAKInfo, rhs: ActorPAKInfo) -> Bool {
        return lhs.actorId == rhs.actorId && lhs.pakId == rhs.pakId
    }
}

//------------主菜单功能----------------
//MARK: 主菜单工具类型，按顺序排列
enum MainToolType : UInt8,CaseIterable
{
    case MainView           = 0     //主视角
    case KeJianXing                 //可见性
    case PersonView                 //人称切换
    case PouQie                     //剖切
    case Celiang                    //测量
    case BiaoQian                   //标签
    case FenJie                     //分解
    case GouJianShu                 //构件树
    case ShuXing                    //属性
}
//MARK: 主菜单工具的使用场景
enum MainToolUsageScenariosType : UInt8
{
    case None       = 0     //没有使用
    case ThreeD             //只在3D下
    case AR                 //只在AR下
    case Both               //3D,AR
}

//MARK: 主菜单单个工具信息
struct MainToolInfo
{
    var type: MainToolType!
    var usageType: MainToolUsageScenariosType!
    var imageName: String = ""
    var labelName: String = ""
    
    var secondTools: [SecondToolType:SecondToolInfo]?
    
    init(_ type: MainToolType,_ usageType: MainToolUsageScenariosType,_ imageName: String,_ labelName: String)
    {
        self.type = type
        self.usageType = usageType
        self.imageName = imageName
        self.labelName = labelName
        
        secondTools = getSecondToolsByMainTool(self.type)
    }
}

//MARK: 主菜单所有工具信息集合
struct MainToolsInfo
{
    var info: [MainToolType:MainToolInfo] = [:]  //当前工具及其对应的使用场景
    
    init()
    {
        initInfo()
    }
    
    mutating func initInfo()
    {
        info[.MainView]       = MainToolInfo(.MainView,.ThreeD, "mainview", "主视图")
        info[.KeJianXing]     = MainToolInfo(.KeJianXing,.Both,"kejianxing","可见性")
        info[.PersonView]     = MainToolInfo(.PersonView,.ThreeD,"personview","视角切换")
        info[.PouQie]         = MainToolInfo(.PouQie,.None,"pouqie","剖切")
        info[.Celiang]        = MainToolInfo(.Celiang,.Both,"celiang","测量")
        info[.BiaoQian]       = MainToolInfo(.BiaoQian,.Both,"biaoqian","标签")
        info[.FenJie]         = MainToolInfo(.FenJie,.Both,"fenjie","分解")
        info[.GouJianShu]     = MainToolInfo(.GouJianShu,.Both,"goujianshu","构件树")
        info[.ShuXing]        = MainToolInfo(.ShuXing,.Both,"shuxing","属性")
        
    }
}

//--------子功能-------------------
//MARK: 人称
enum PersonViewType : UInt8
{
    case FP     = 0
    case TP     = 1
}

//MARK: 测量类型
enum MeasurementType: UInt8 {
    case coordinate                 = 0
    case distance                   = 1
    case angle                      = 2
    case changePrecisionOrUnit      = 3
}

enum KeJianXingType: UInt8
{
    case yincang                    = 0
    case geli                       = 1
    case xianshiquanbu              = 2
}

enum SecondToolType: Hashable,Equatable
{
    case PVT(PersonViewType)
    case MMT(MeasurementType)
    case KJX(KeJianXingType)
    
    
    static func ==(lhs: SecondToolType, rhs: SecondToolType) -> Bool {
        var result = false
        switch (lhs, rhs) {
        case (.PVT(let lt), .PVT(let rt)):
            result = lt == rt; break
        case (.MMT(let lt), .MMT(let rt)):
            result = lt == rt; break
        case (.KJX(let lt), .KJX(let rt)):
            result = lt == rt
        default:
            break
        }
        return result
    }
}
//MARK: 二级功能按钮存在类型: 暂时没有使用
enum SecondToolExistType : UInt8
{
    case GongCun    = 0  //可以与别的其他类型同时存在，除了PaiChi
    case HuChi      = 1  //将其他HuChi的类型关闭，最多只存在一个HuChi
    case PaiChi     = 2  //可以将前面其他类型全关闭，只存在自己
}

//MARK: 二级单个工具信息
struct SecondToolInfo
{
    var type: SecondToolType!
    var imgName: String = ""
    var labName: String = ""
    
    init(_ type: SecondToolType, _ imgName: String, _ labName: String) {
        self.type = type
        self.imgName = imgName
        self.labName = labName
    }
}

//------------------ Func ----------------------

//MARK: 判断tool type在当前screenmode下是否有效
func validOfScreenModeAndToolType(_ screenMode: car_ScreenMode,_ toolType: MainToolType) -> Bool
{
    var result = false
    if let usageScenarios = car_EngineStatus.mainToolsInfo.info[toolType]?.usageType {
        switch screenMode {
        case .None:
            break
        case .AR:
            result = (usageScenarios == .AR || usageScenarios == .Both)
        case .ThreeD:
            result =  (usageScenarios == .ThreeD || usageScenarios == .Both)
        }
    }
    return result
}

func getMainToolImgName(_ toolType: MainToolType) -> String?
{
    return car_EngineStatus.mainToolsInfo.info[toolType]?.imageName
}
func getMainToollabName(_ toolType: MainToolType) -> String?
{
    return car_EngineStatus.mainToolsInfo.info[toolType]?.labelName
}
func getSecondToolsByMainTool(_ toolType: MainToolType) -> [SecondToolType:SecondToolInfo]?
{
    var info: [SecondToolType: SecondToolInfo] = [:]
    switch toolType {
    case .MainView: break
    case .PersonView:
        info[SecondToolType.PVT(.FP)] = SecondToolInfo(.PVT(.FP), "firstperson", "FP")
        info[SecondToolType.PVT(.TP)] = SecondToolInfo(.PVT(.TP), "thirdperson", "TP")
        break
    case .GouJianShu: break
    case .ShuXing: break
    case .Celiang:
        info[SecondToolType.MMT(.distance)] = SecondToolInfo(.MMT(.distance),"measure_distance","distance")
        info[SecondToolType.MMT(.angle)] = SecondToolInfo(.MMT(.angle),"measure_angle","angle")
        info[SecondToolType.MMT(.coordinate)] = SecondToolInfo(.MMT(.coordinate),"measure_coordinate","coordinate")
        info[SecondToolType.MMT(.changePrecisionOrUnit)] = SecondToolInfo(.MMT(.changePrecisionOrUnit),"measure_change","change")
        break
    case .BiaoQian: break
    case .KeJianXing:
        info[SecondToolType.KJX(.yincang)] = SecondToolInfo(.KJX(.yincang),"yincang","yincang")
        info[SecondToolType.KJX(.geli)] = SecondToolInfo(.KJX(.geli),"geli","geli")
        info[SecondToolType.KJX(.xianshiquanbu)] = SecondToolInfo(.KJX(.xianshiquanbu),"xianshiquanbu","xianshiquanbu")
        break
    case .FenJie: break
    case .PouQie: break
    }
    return info.count == 0 ? nil : info
}
func getSecondToolImgName(_ mainType: MainToolType,_ secondType: SecondToolType) -> String?
{
    return car_EngineStatus.mainToolsInfo.info[mainType]?.secondTools?[secondType]?.imgName
}
func getSecondToollabName(_ mainType: MainToolType,_ secondType: SecondToolType) -> String?
{
    return car_EngineStatus.mainToolsInfo.info[mainType]?.secondTools?[secondType]?.labName
}
func hasSecondTools(_ mainType: MainToolType) -> Bool
{
    if let secondTools = car_EngineStatus.mainToolsInfo.info[mainType]?.secondTools {
        if secondTools.count != 0 {
            return true
        }
    }
    return false
}
func getEngineDefaultSecondTool(_ mainType: MainToolType) -> [SecondToolType]
{
    var secondTools: [SecondToolType] = []
    if hasSecondTools(mainType) {
        switch mainType {
        case .PersonView:
            secondTools.append(SecondToolType.PVT(car_EngineStatus.personview))
        default:
            break
        }
    }
    return secondTools
}
func getMainToolsByOrder() ->[MainToolType] {
    if car_EngineStatus.mainToolsOrder.isEmpty {
        var orders:[MainToolType] = []
        for type in MainToolType.allCases {
            switch type {
            case .MainView: orders.append(type)
            case .KeJianXing: orders.append(type)
            case .PersonView: orders.append(type)
            case .PouQie: orders.append(type)
            case .Celiang: orders.append(type)
            case .BiaoQian: orders.append(type)
            case .FenJie: orders.append(type)
            case .GouJianShu: orders.append(type)
            case .ShuXing: orders.append(type)
            }
        }
        car_EngineStatus.mainToolsOrder = orders
    }
    return car_EngineStatus.mainToolsOrder
}
func getSecondToolsByOrder(_ mainTool: MainToolType) -> [SecondToolType]? {
    if car_EngineStatus.secondToolsOrder.isEmpty {
        var orders:[MainToolType: [SecondToolType]] = [:]
        for type in MainToolType.allCases {
            switch type {
            case .MainView:
                orders[type] = []
                break
            case .KeJianXing:
                orders[type] = [.KJX(.yincang),.KJX(.geli),.KJX(.xianshiquanbu)]
                break
            case .PersonView:
                orders[type] = [.PVT(.FP),.PVT(.TP)]
                break
            case .PouQie:
                orders[type] = []
                break
            case .Celiang:
                orders[type] = [.MMT(.coordinate),.MMT(.distance),.MMT(.angle),.MMT(.changePrecisionOrUnit)]
                break
            case .BiaoQian:
                orders[type] = []
                break
            case .FenJie:
                orders[type] = []
                break
            case .GouJianShu:
                orders[type] = []
                break
            case .ShuXing:
                orders[type] = []
                break
            }
        }
        
        car_EngineStatus.secondToolsOrder = orders
    }
    return car_EngineStatus.secondToolsOrder[mainTool]
}
