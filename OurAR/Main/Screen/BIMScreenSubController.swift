//
//  BIMScreenController.swift
//  OurAR
//
//  Created by lee on 2023/6/2.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import UIKit
import Foundation
import CloudAR
import WebKit
import SVProgressHUD

class BIMScreenSubController : UIViewController, MainToolProtocol,SocketEventProtocol
{
    
    var vjBIMScreenView: BIMSubScreenView!
    var wsReceiverHandler: WSReceiverHandler! //专门处理websocket消息
    
    //目前miantool只能选中一个，secondTool可以选中多个
    var clickedMT: MainToolType? //当前所点击的mainTool（直接触发的不算）
    var clickedST: [SecondToolType] = [] //当前所点击的secondTools
    
    var clickedActorID: Set<ActorPAKInfo> = [] //引擎中所点击的actorIDs
    deinit {
        print("-----BIMScreenSubController - deinit")
    }
    override func loadView() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        // 替换默认的UIView
        vjBIMScreenView = BIMSubScreenView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        vjBIMScreenView.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.view = vjBIMScreenView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerGesture()
        
        VJMTDelegateManager.add(self)
        SEDelegateManager.add(self)
        wsReceiverHandler = WSReceiverHandler(vjBIMScreenSubController: self)
    }
    
    func removeSubDelegate() {
        SEDelegateManager.remove(self)
        VJMTDelegateManager.remove(self)
    }
    
    private func registerGesture() {
        // 单击手势
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(singleTapGesture)
        
        // 拖动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        // 添加手势到视图
        panGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(panGesture)
    }
    
    //MARK: 监听screen mode的切换
    func listenSwitchScreenMode(toScreenMode: car_ScreenMode) {
        // 数据的清除
        clickedMT = nil
        clickedST = []
        clickedActorID = []
        // 页面的调整
        vjBIMScreenView!.listenSwitchScreenMode(toScreenMode: toScreenMode)
        // threeD <---> ar btn
        vjBIMScreenView?.vjSwitchModeView?.changeSwitchBG(toScreenMode: toScreenMode)
    }
    /**
     var exitScreenBtn: BackBtnView! //场景退出按钮
     var vjSwitchModeView: SwitchModeView! //模式切换按钮
     var sliderView: SliderView! //
     var vjMainToolView: MainToolView! //主工具栏
     var vjSecondToolViews: [MainToolType: SecondToolView] = [:] //二级工具栏集
     
     var vjPropertyView: VJPropertyView! //属性面板
     var vjTagView: TagView! //标签面板
     var vjGJSView: GoujianshuView! //构件树面板
     var vjFenJieView: FenJieView! //分解面板
     
     var enterPositionView: EnterPositionView! //进入定位按钮
     */
    
    //MARK: Gesture
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: self.view)
            if !vjBIMScreenView.vjPropertyView.isHidden && CGRectContainsPoint(vjBIMScreenView.vjPropertyView.frame, point)
                || !vjBIMScreenView.exitScreenBtn.isHidden && CGRectContainsPoint(vjBIMScreenView.exitScreenBtn.frame, point)
                || !vjBIMScreenView.sliderView.isHidden && CGRectContainsPoint(vjBIMScreenView.sliderView.frame, point)
                || !vjBIMScreenView.vjMainToolView.isHidden && CGRectContainsPoint(vjBIMScreenView.vjMainToolView.frame, point)
                || !vjBIMScreenView.vjTagView.isHidden && CGRectContainsPoint(vjBIMScreenView.vjTagView.frame, point)
                || !vjBIMScreenView.vjGJSView.isHidden && CGRectContainsPoint(vjBIMScreenView.vjGJSView.frame, point)
                || !vjBIMScreenView.vjFenJieView.isHidden && CGRectContainsPoint(vjBIMScreenView.vjFenJieView.frame, point)
                || !vjBIMScreenView.enterPositionView.isHidden && CGRectContainsPoint(vjBIMScreenView.enterPositionView.frame, point) {
            }else {
                car_sendClickGesture(point: point, size: self.view.bounds.size) { result in }
            }
        }
        
    }
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let state = sender.state == .began ? car_InputState.began : sender.state == .changed ? .changed : .ended
        car_sendPanGesture(point: translation, size: view.frame.size,state: state, completion: {_ in })
    }
    
    //MARK: VJMainToolProtocol唯一的监听 监听maintool的点击
    func handleMainToolClick(type: MainToolType) {
        //直接触发型直接发送:没有关闭选项
        var isDirect = false
        switch type {
        case .MainView:
            isDirect = true
            break
        case .PersonView: break
        case .GouJianShu: break
        case .ShuXing: break
        case .Celiang: break
        case .BiaoQian: break
        case .KeJianXing: break
        case .FenJie: break
        case .PouQie: break
        }
        //直接触发型，直接发送
        if isDirect {
            sendEventMainToolOpen(main: type, completion: {result in print("direct type:\(type): send \(result)")})
            return
        }
        //可能是开可能是关 取决于clickedMT是否等于type
        handleMainToolOpenOrClose(type: type)
    }
    //MARK: 监听mainTool的关闭
    func handleMainToolClose(type: MainToolType) {
        if clickedMT == nil {
            return
        }
        if clickedMT != type {
            return
        }
        var isDirect = true
        switch type {
        case .MainView:
            break
        default:
            isDirect = false
            break;
        }
        if isDirect {
            return
        }
        //一定是关闭:当前的clickedMT == type
        handleMainToolOpenOrClose(type: type)
    }
    
    private func handleMainToolOpenOrClose(type: MainToolType) {
        //处理view相关的页面
        vjBIMScreenView?.handleMainToolClick(type,clickedMT)
        //如果上一个tool存在，则发送关闭
        if clickedMT != nil {
            // maintool 关闭
            sendEventMainToolClose(main: clickedMT!) { result in
                print("关闭:\(result)")
            }
        }
        //更新mainToolType
        if clickedMT == nil || clickedMT != type {
            clickedMT = type
        } else {
            clickedMT = nil
        }
        //清空当前所点击的secondTool
        clickedST.removeAll()
        //如果新的tool不为nil，则发送开启
        if clickedMT != nil {
            // maintool 开启
            sendEventMainToolOpen(main: clickedMT!) { result in
                print("\(String(describing: self.clickedMT)),开启: \(result)")
            }
            //开启maintool，有引擎默认的second tool时，设置默认值并高亮,默认值不需要更新指令
            clickedST = getEngineDefaultSecondTool(clickedMT!)
            vjBIMScreenView?.showCurrSecondTools(clickedMT!, clickedST)
        }
    }
   
    //MARK:  监听secondtool的点击
    func handleSecondToolClick(mainType: MainToolType,type: SecondToolType) {
        if clickedMT == nil || clickedMT != mainType {
            print("current maintooltype not equal: \(self.clickedST) != \(mainType)")
            return
        }
        
        var needUpdate = false
        //这里的逻辑处理就比较复杂
        //点击就是开启，如果clickedST包含了就说明已经开启了，就不需要再重新开启了
        if mainType == .PersonView {
            if !clickedST.contains(type) {
                clickedST.removeAll()
                clickedST.append(type)
                needUpdate = true
                car_EngineStatus.personview = type == .PVT(.FP) ? .FP : .TP
            }
        } else if mainType == .Celiang {
            if !clickedST.contains(type) {
                clickedST.removeAll()
                clickedST.append(type)
                needUpdate = true
            }
        } else if mainType == .KeJianXing {
            if !clickedST.contains(type) {
                clickedST.removeAll()
                clickedST.append(type)
                needUpdate = true
            }
        }
        
        //更新
        if needUpdate {
            // 更新二级功能的展示
            vjBIMScreenView?.showCurrSecondTools(mainType, clickedST)
            // 发送指令,最麻烦了.这里把所有功能请求放到一个函数里面进行请求
            sendEventBySecondTypes(main: mainType, seconds: clickedST,params: [:]) {result,msg in
                if !result {
//                    SVProgressHUD.show(withStatus: msg)
//                    SVProgressHUD.dismiss(withDelay: 2)
                }
            }
        }
    }

    
    //MARK: 处理监听socket消息: 目前是从BIMScreenController传过来的
    //MARK: SocketEventProtocol
    // 统一交给 wsReceiverHandler去处理
    func handleReceiverMsg(json: inout [String : Any]) {
        if let id = json["id"] as? String {
            wsReceiverHandler.handleReceiverMsg(id: id, json: &json)
        }
    }
    
}
