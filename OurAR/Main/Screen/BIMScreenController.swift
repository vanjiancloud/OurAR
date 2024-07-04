//
//  BIMScreenController.swift
//  OurAR
//
//  Created by lee on 2023/6/2.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import UIKit
import Foundation
import MetalKit
import CloudAR
import Alamofire
import SVProgressHUD

class BIMScreenController : UIViewController,SwitchScreenModeProtocol,ModelLaunchProtocol,ARPositionProtocol
,ModelLoadFinishProtocol,CloudXRConnectProtocol,EnterPositionPtocotol,CloudXRClientStateUpdateProtocol
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//MARK: property
    //AR
    var arModelController: ARModelController?   //ar画面
//    var connectStatsTimer: Timer?
    
    //ThreeD
    var threeDModelController: ThreedModelController? //threeD画面
    
    //Tool
    var vjBIMScreenSubController: BIMScreenSubController!  //模型操作工具画面
    var modelLoadController: ModelLoadViewController!  //ar加载页面
    var timer:Timer?
    
//MARK: self func
    deinit {
        print("-----BIMScreenController - deinit")
    }
    override func loadView() {
        //重设 view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.allowRotation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.allowRotation = false
        //判断退出时是否是横屏
            if UIApplication.shared.statusBarOrientation.isLandscape {
                //是横屏让变回竖屏
                setNewOrientation(fullScreen: false)
            }
    }
    //横竖屏
    func setNewOrientation(fullScreen: Bool) {
        if fullScreen { //横屏
            let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
            UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
            
            let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.landscapeLeft.rawValue)
            UIDevice.current.setValue(orientationTarget, forKey: "orientation")
            
        }else { //竖屏
            let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
            UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
            
            let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue)
            UIDevice.current.setValue(orientationTarget, forKey: "orientation")
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SSMDelegateManager.add(self)
        MLDelegateManager.add(self)
        EPDelegateManager.add(self)
        self.view = BIMScreenView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.backgroundColor = .white
        initSubController()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc func appWillTerminate() {
        print("appWillTerminate")
        WebSocketClient.shared.close()
        if car_EngineStatus.screenMode == .AR {
            if arModelController != nil {
                sendModelQuit { [weak self](result, msg) in
                    print("-----模型关闭-----");
                    self?.timer?.invalidate();
                    self?.timer = nil;
                }
                self.performSelector(onMainThread: #selector(addTimerAction), with: nil, waitUntilDone: true)
            }
            removeARView()
        }else if car_EngineStatus.screenMode == .ThreeD {
            removeThreeDView()
        }
        
    }
    
    @objc func addTimerAction() {
        if  self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
            RunLoop.current .add(self.timer!, forMode: .default)
            RunLoop.current .run()
        }
    }
    @objc func startTimer() {
        print("---")
    }
    private func initSubController()
    {
        vjBIMScreenSubController = BIMScreenSubController()
        addChild(vjBIMScreenSubController)
        view.insertSubview(vjBIMScreenSubController!.view, at: 1)
        vjBIMScreenSubController.didMove(toParent: self)
        vjBIMScreenSubController.view.backgroundColor = UIColor(white: 1, alpha: 0)
        vjBIMScreenSubController.view.snp.makeConstraints { make in
            make.right.left.top.bottom.equalTo(self.view)
        }
        
        modelLoadController = ModelLoadViewController()
        modelLoadController.modelLoadFinishProtocol = self
        modelLoadController.finishBlock = {[weak self](t:Bool) in
            self?.addArModelController()
        }
        addChild(modelLoadController)
        view.insertSubview(modelLoadController!.view, at: 2)
        modelLoadController!.didMove(toParent: self)
    }
    
    //MARK: 监听screenMode的切换 ar <---> threeD
    func handleSwitchScreenMode(toScreenMode: car_ScreenMode) {
        // 关闭上一个模式的模型，发送关闭通知
//        sendModelQuit(screenType: toScreenMode == .AR ? .ThreeD : .AR)
        vjBIMScreenSubController!.view.isHidden = true
        modelLoadController!.view.isHidden = false
        sendModelQuit { [weak self](result, msg) in
            print("-----模型关闭-----");
            self?.removeAllSetting()
            //加载新模式的模型
            self?.LoadModel(projectID: car_UserInfo.currProID, screenType: toScreenMode)
        }
    }
    
    //MARK: VJModelLaunchProtocol 监听模型关闭
    func handleModelClose() {
        sendModelQuit { (result, msg) in
            print("-----模型关闭-----");
            self.closeScreenPageView()
        }
    }
    
    //MARK: VJARPositionProtocol 监听定位完成
    func handleConfirmPosition(type: car_ARPositionType) {
        switch type {
        case .None:
            break
        case .ScanPosition:
            vjBIMScreenSubController?.view.isHidden = false
            vjBIMScreenSubController?.view.isUserInteractionEnabled = true
            vjBIMScreenSubController?.vjBIMScreenView?.vjMainToolView?.isHidden = false
        case .SpacePosition:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func handleCanclePosition() {
        vjBIMScreenSubController?.view.isHidden = false
        vjBIMScreenSubController?.view.isUserInteractionEnabled = true
        vjBIMScreenSubController?.vjBIMScreenView?.vjMainToolView?.isHidden = false
    }
    
    func printConnectStats() {
//        connectStatsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
//            if car_EngineStatus.screenMode == .AR {
//                let (isSuccess,quality,reason) = self.arModelController!.getConnectQuality()
//                print("success:\(isSuccess),quality: \(String(describing: quality)),reason: \(String(describing: reason))")
//            } else {
//                timer.invalidate()
//            }
//        }
//        connectStatsTimer?.fire()
    }
    
    //MARK: 根据场景类型来加载模型
    func LoadModel(projectID: String,screenType: car_ScreenMode) {
        car_EngineStatus.screenMode = screenType
        modelLoadController!.loadInfo = (projectID,screenType)
        switch screenType {
            case .AR:
                modelLoadController!.queryLoadModel()
                break
            case .ThreeD:
                // threeD嵌入在vjBIMScreenSubControll中作为subview
                threeDModelController = ThreedModelController()
                vjBIMScreenSubController.addChild(threeDModelController!)
                vjBIMScreenSubController.view.insertSubview(threeDModelController!.view, at: 0)
                threeDModelController!.didMove(toParent: vjBIMScreenSubController)
                vjBIMScreenSubController!.view.isHidden = false
                modelLoadController?.loadThreeDURLProcotol = threeDModelController
                modelLoadController!.queryLoadModel()
                
                break
            case .None:
                break
            default:
                break
        }
    }
    
    func addArModelController() {
        arModelController = ARModelController()
        arModelController?.notityConnectProtocol = self
        arModelController?.arPositionProtocol = self
        arModelController?.notifyClientStateUpdateProtocol = self
        addChild(arModelController!)
        view.insertSubview(arModelController!.view, at: 0)
        arModelController!.didMove(toParent: self)
    }
    
    //MARK: VJModelLoadFinishProtocol  监听模型加载完成
    func handleModelLoadFinish(isSuccess: Bool, reason: String, screenType: car_ScreenMode, project: String) {
        if isSuccess {
            print("模型启动成功")
            // 记录场景模式和项目id
            car_EngineStatus.screenMode = screenType
            car_UserInfo.currProID = project
            
            vjBIMScreenSubController!.view.isHidden = false
            
            modelLoadController!.view.isHidden = true
            
            // 重置主菜单的数据
            vjBIMScreenSubController!.listenSwitchScreenMode(toScreenMode: screenType)
            
//            screenType == .AR ? printConnectStats() : ()
            
        } else {
            print("模型启动失败-\(reason)")
            let showView = self.modelLoadController!.view.isHidden ? self.view : self.modelLoadController!.view
//            showTip(tip: reason, parentView: showView ?? self.view, tipColor_bg_fail, tipColor_text_fail) {
            SVProgressHUD.showInfo(withStatus: reason)
                MLDelegateManager.notity()
//            }
        }
    }
    
    //MARK: cloudxr连接通知
    func notifyConnect(connected: Bool) {
        if connected {
            if modelLoadController != nil {
                modelLoadController!.addArModelLoad()
            }
        } else {
            //cloudxr如果没有连接成功，需要立即删除arModelController
            handleModelLoadFinish(isSuccess: false, reason: "cloudxr连接失败", screenType: .AR, project: "")
        }
    }
    
    //MARK: cloudxr重连通知
    func notifyReconnect(connected: Bool) {
        if connected {
        } else {
            //cloudxr如果没有连接成功，需要立即删除arModelController
            handleModelLoadFinish(isSuccess: false, reason: "cloudxr重连失败", screenType: .AR, project: "")
        }
    }
    
    func notifyServerDisConnect() {
        let alert = UIAlertController(title: "提示", message: "服务器连接已断开，是否返回", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "是", style: .default) { [weak self]_ in
            self?.handleModelLoadFinish(isSuccess: false, reason: "返回成功", screenType: .AR, project: "")
        }
        let cancleAction = UIAlertAction(title: "否", style: .default) { _ in
        }
        alert.addAction(cancleAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func notifyClientStateUpdate(state: car_ClientState,reason: car_ClientStateReason) {
        switch state {
        case .connectionAttemptFailed:print("notifyClientStateUpdate -- connectionAttemptFailed")
            break
        case .disconnected:
            if(arModelController != nil) {
                DispatchQueue.main.async {
                    self.addAlertPopView ()
                }
            }
            break
        case .readyToConnect:print("notifyClientStateUpdate -- readyToConnect")
            break
        case .connectionAttemptInProgress:print("notifyClientStateUpdate -- connectionAttemptInProgress")
            break
        case .streamingSessionInProgress:print("notifyClientStateUpdate -- streamingSessionInProgress")
            break
        case .exiting:print("notifyClientStateUpdate -- exiting")
            break
        @unknown default:print("notifyClientStateUpdate -- default")
            fatalError()
        }
    }
    
    func addAlertPopView () {
        // 创建一个弹窗
        let alert = UIAlertController(title: "提示", message: "客户端连接已断开，是否重连", preferredStyle: .alert)
        // 创建一个按钮，用于关闭弹窗
        let okAction = UIAlertAction(title: "是", style: .default) { [weak self]_ in
            // 点击“确定”后的处理
            let result = self?.arModelController?.reconnect()
            let success = result?.0
            let reason = result?.1
            if success! {
                print("开始重连")
            }else {
                print("不能重连")
                self?.handleModelLoadFinish(isSuccess: false, reason: reason!, screenType: .AR, project: "")
            }
        }
        let cancleAction = UIAlertAction(title: "否", style: .default) { [weak self]_ in
            self?.handleModelLoadFinish(isSuccess: false, reason: "不接受重连，返回成功", screenType: .AR, project: "")
        }
        // 将按钮添加到弹窗上
        alert.addAction(cancleAction)
        alert.addAction(okAction)
        // 显示弹窗
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: 监听进入定位,默认是扫码定位
    func handleEnterPosition() {
        vjBIMScreenSubController!.view.isHidden = true
        car_EngineStatus.arPositionType = .ScanPosition //切换screenmode后默认是扫码定位
        arModelController?.enterPosition(positionType: car_EngineStatus.arPositionType)
    }
    
    //MARK: 关闭移除
    func  closeScreenPageView() {
//        self.connectStatsTimer?.invalidate()
//        self.connectStatsTimer = nil
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        SSMDelegateManager.remove(self)
        MLDelegateManager.remove(self)
        EPDelegateManager.remove(self)
        modelLoadController?.removeSEDelegate()
        vjBIMScreenSubController?.removeSubDelegate()
        removeARView()
        removeThreeDView()
        removeModelLoadView()
        removeVjBimScreenSubView()
        car_UserInfo.currProID = ""
        car_UserInfo.taskID = ""
        if car_EngineStatus.screenMode == .AR {
            car_EngineStatus.lastExitARTime = Date().timeStamp //记录退出时间
        }
        car_EngineStatus.screenMode = .None
        print("-----dismiss-----");
        self.dismiss(animated: false)
    }
    
    func removeAllSetting() {
        print("removeAllSetting - close")
        WebSocketClient.shared.close() //断开与java的websocket
//        self.connectStatsTimer?.invalidate()
//        self.connectStatsTimer = nil
        if car_EngineStatus.screenMode == .AR {
            removeThreeDView()
        }else if car_EngineStatus.screenMode == .ThreeD {
            removeARView()
        }
    }
    
    func removeModelLoadView() {
        if modelLoadController != nil {
            modelLoadController?.removeFromParent()
            modelLoadController?.view.removeFromSuperview()
            modelLoadController = nil
        }
    }
    
    func removeVjBimScreenSubView() {
        if vjBIMScreenSubController != nil {
            vjBIMScreenSubController?.removeFromParent()
            vjBIMScreenSubController?.view.removeFromSuperview()
            vjBIMScreenSubController = nil
        }
    }
    
    func removeThreeDView() {
        if threeDModelController != nil {
            threeDModelController?.removeFromParent()
            threeDModelController?.view?.removeFromSuperview()
            threeDModelController = nil
        }
    }
    
    func removeARView() {
        if arModelController != nil {
            requestExitByHostId { result in
                if result {
                    print("-----重启服务器成功")
                }else {
                    print("-----重启服务器失败")
                }
            }
            DispatchQueue.main.async {
                self.arModelController?.closeARModel()
            }
            arModelController?.removeFromParent()
            arModelController?.view.removeFromSuperview()
            arModelController = nil
        }
    }
}
