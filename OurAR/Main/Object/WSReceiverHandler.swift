//
//  WSReceiverHandler.swift
//  OurAR
//
//  Created by lee on 2023/7/31.
//

import Foundation

//
final class WSReceiverHandler
{
    var vjBimC: BIMScreenSubController!
    
    init(vjBIMScreenSubController: BIMScreenSubController!) {
        self.vjBimC = vjBIMScreenSubController
    }
    
    func handleReceiverMsg(id: String,json: inout [String:Any]) {
        switch id {
        case "1":
            //鼠标单击选中构件
            if let actorID = json["mN"] as? String,
               let pakID = json["pakId"] as? String
            {
                vjBimC.clickedActorID.removeAll()
                if !actorID.isEmpty {
                    vjBimC.clickedActorID.insert(ActorPAKInfo(actorId: actorID, pakId: pakID))
                    print("click actor id: \(actorID)")
                }
            }
            //属性面板的更新
            if vjBimC.clickedMT != nil && vjBimC.clickedMT == .ShuXing {
                vjBimC?.vjBIMScreenView?.updatePropertyView(&json)
            }
            break
        case "2":
            //无
            break
        case "3":
            //添加关注视角后返回关注视角信息: 用不到
            break
        case "4":
            //设置主视图后返回主视图信息: 用不到
            break
        case "5":
            //多个构件被选中
            break
        case "6":
            //场景加载事件: 可有可无
            break
        case "7":
            //点击空白位置
            vjBimC?.clickedActorID.removeAll()
            //属性面板的更新
            if vjBimC.clickedMT != nil && vjBimC.clickedMT == .ShuXing {
                vjBimC?.vjBIMScreenView?.updatePropertyView("", "")
            }
            break
        case "8":
            //场景渲染进度指令（progress=1场景加载完成）: 可有可无
            break
        case "9":
            //点击标签定位视角事件
            break
        case "10":
            //标签新建成功后返回信息
            break
        case "11":
            //标签被删除后返回信息
            break
        case "12":
            //去除遮罩指令（progress=1场景加载完成）
            break
        case "13":
            //无
            break
        case "14":
            //取消添加构件
            break
        case "15":
            //构件编辑操作状态打开时，点击构件返回信息，关闭构件编辑状态也返回关闭信息
            break
        default:
            
            break
        }
    }
}
