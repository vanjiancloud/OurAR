//
//  VJLoadViewController.swift
//  CloudXRClient
//
//  Created by lee on 2023/6/5.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation
import UIKit
import CloudAR
import Alamofire


class VJModelLoadViewController: UIViewController, VJSocketEventProtocol
{
    var modelLoadView: VJModelLoadView!
    var loadProgress: CGFloat = 0.0
    
    private var tokenRequest: DataRequest?
    private var modelLoadRequest: DataRequest?
    
    var needLoadProjectID: String = "" //需要加载的projectid
    
    var maxConnectCount: Int = 100
    
    override func loadView() {
        //self.view.frame
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        modelLoadView = VJModelLoadView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        modelLoadView.backBtn.btn.addAction(UIAction(handler: {_ in
            self.cancelLoadModel()
        }), for: .touchUpInside)
        self.view = modelLoadView
        
        tokenRequest = nil
        modelLoadRequest = nil
        
        VJSEDelegateManager.add(self)
    }
    
    deinit {
        VJSEDelegateManager.remove(self)
    }
    
    func listenModelLaunch(isLaunch: Bool,_ success: Bool)
    {
        if isLaunch && success {
            if success {
                //停止加载动画
                self.showLoadAnim(false)
                //将加载页面移除
                self.presentingViewController?.dismiss(animated: false)
                //进入主场景页面
                enterBIMScreen(currViewController: self.presentingViewController ?? self)
            }
        } else {
            //存储 project id
            car_VJUserInfo.currProID = ""
            //存储 taskid
            car_VJUserInfo.taskID = ""
            //停止加载动画
            self.showLoadAnim(false)
            //将加载页面移除
            self.presentingViewController?.dismiss(animated: false)
           
        }
    }
    
    //查询加载进度
    private func queryLoadProgress()
    {
        let timer: Timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            if self.loadProgress >= 1 {
                timer.invalidate()
                self.listenModelLaunch(isLaunch: true,true)
            }
        }
        timer.fire()
    }

    //请求模型加载
    func queryLoadModel(projectID:String)
    {
        print("query load model")
        
        loadProgress = 0.0 //重置加载进度
        self.showLoadAnim(true) //展示加载动画
        //开始请求模型加载
        
        //MARK: ourbim 请求模型加载接口
        let auth = UserDefaults.standard.string(forKey: "username") ?? ""
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
        print("auth:\(auth),password:\(password),projectID:\(projectID)")
        
        queryTokenForLoadModel(request:&tokenRequest,auth: auth, password: password, projectID: projectID) { result in
            switch result {
            case .success(let token):
                queryModelLoad(request:&self.modelLoadRequest,token: token, projectID: projectID) { (result,msg) in
                    if result {
                        VJWebSocketClient.shared.connect()
                        self.queryLoadProgress()
                    } else {
                        showTip(tip: msg, parentView: self.view, tipColor_bg_fail, tipColor_text_fail) {
                            self.listenModelLaunch(isLaunch: true, false)
                        }
                    }
                }
            case .failure(let error):
                print("\(#function),\(error),get token failed")
                showTip(tip: error.localizedDescription, parentView: self.view,tipColor_bg_fail, tipColor_text_fail) {
                    self.listenModelLaunch(isLaunch: true, false)
                }
            }
        }
    }
    
    //MARK: 在加载页面中取消模型的加载
    func cancelLoadModel()
    {
        tokenRequest?.cancel() //取消token的request
        modelLoadRequest?.cancel() //取消modelload的request
        tokenRequest = nil
        modelLoadRequest = nil
        
        queryModelClose(completion: {result in}) //请求模型关闭
        VJMLDelegateManager.notity() //广播模型关闭
        car_VJUserInfo.currProID = ""
        car_VJUserInfo.taskID = ""
        
        self.presentingViewController?.dismiss(animated: false) //退出model load view & controller
    }
    
    private func showLoadAnim(_ load: Bool)
    {
        if let vjModelLoadView = self.view as? VJModelLoadView
        {
            if load == true
            {
                vjModelLoadView.show()
            }
            else
            {
                vjModelLoadView.hide()
            }
        }
    }
    
    
    func handleReceiverMsg(json: inout [String : Any]) {
        if let id = json["id"] as? String {
            if id == "8" {
                if let progress = json["progress"] as? String {
                    print("场景加载进度：\(progress)")
                    self.loadProgress = CGFloat((progress as NSString).floatValue)
                }
            }
        }
    }
}
