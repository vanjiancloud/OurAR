//
//  ModelLoadViewController.swift
//  OurAR
//
//  Created by lee on 2023/8/17.
//

import Foundation
import UIKit
import Alamofire
import CloudAR

class ModelLoadViewController: UIViewController,SocketEventProtocol {
    typealias BlockWithGetHostIdFinish = (Bool) -> ()
    @objc var finishBlock: BlockWithGetHostIdFinish?
    
    typealias ModelLoadPhaseNotify = (Int) -> ()
    @objc var loadPhaseNotify: ModelLoadPhaseNotify?
    
    var modelLoadView: ModelLoadView!
    
    private var loadProgress: CGFloat = 0.0
    private var tokenRequest: DataRequest?
    private var modelLoadRequest: DataRequest?
    private var arrLoadMessage: NSArray = []
    var loadStepString: String!
    private var loadNumber: NSInteger = 0
    
    private var needLoadProject: String = "" //待加载的项目id
    private var needLoadMode: car_ScreenMode = .None //待加载的模式
    var modelLoadFinishProtocol: ModelLoadFinishProtocol? //项目启动后的代理
    var loadThreeDURLProcotol: ThreeDURLProtocol? //threeD视频流加载代理
    var loadInfo: (String,car_ScreenMode) {
        get {
            return (needLoadProject,needLoadMode)
        }
        set {
            needLoadProject = newValue.0
            needLoadMode = newValue.1
        }
    }
    
    deinit {
        print("-----ModelLoadViewController--deinit--")
    }
    
    func removeSEDelegate() {
        SEDelegateManager.remove(self)
    }
    
    override func viewDidLoad() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        modelLoadView = ModelLoadView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        modelLoadView.backBtn.btn.addAction(UIAction(handler: {[weak self]_ in
            self?.tokenRequest = nil
            self?.modelLoadRequest = nil
            MLDelegateManager.notity()
        }), for: .touchUpInside)
        self.view = modelLoadView
        
        tokenRequest = nil
        modelLoadRequest = nil
        
        SEDelegateManager.add(self)
    }
    
    func handleReceiverMsg(json: inout [String : Any]) {
        print("\(json)")
        if let id = json["id"] as? String {
            if id == "8" {
                if let progress = json["progress"] as? String {
                    self.loadProgress = CGFloat((progress as NSString).floatValue)
                    
                    if self.needLoadMode == .AR {
                        self.modelLoadView.progressView.setProgress(Float(self.loadProgress), animated: true)
                        
                        let percent = Int(self.loadProgress * 100)
                        self.modelLoadView.progressLabel.text = "\(percent)%"
                        
                        if percent > 0 {
                            self.modelLoadView.progressBgView.backgroundColor = UIColor(red: 0.0706, green: 0.5882, blue: 0.8588, alpha: 1.0)
                        }
                            
                        var barOffset = 300 * CGFloat(self.loadProgress)
                        if barOffset < 22 {
                            barOffset = 22;
                        }
                        self.modelLoadView.progressBgWidthConstraint.constant = barOffset
                        
                        var labelOffset = barOffset - 50
                        if labelOffset < 22-50 {
                            labelOffset = 22-50
                        }
                        self.modelLoadView.progressLabelLeadingConstraint.constant = max(0, labelOffset)

                        UIView.animate(withDuration: 0.01) {
                            self.modelLoadView.layoutIfNeeded()
                        }
                    }
                }
            } else if id == "6" {
                self.loadPhaseNotify?(6)
            }
        }
    }
    
    func showLoadAnim(_ load: Bool) {
        if let vjModelLoadView = self.view as? ModelLoadView {
            load ? vjModelLoadView.show() : vjModelLoadView.hide()
        }
    }
    
    //查询加载进度
    private func queryLoadProgress() {
        let timer: Timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            if self.loadProgress >= 1 {
                print("load progress > 1")
                timer.invalidate()
                self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: true, reason: "", screenType: self.needLoadMode, project: self.needLoadProject)
                self.needLoadProject = ""
                self.needLoadMode = .None
              
                self.arrLoadMessage = []
                self.loadNumber = 0
                self.modelLoadView.stepLabel.text = ""
                
                self.modelLoadView.progressView.alpha = 0.0
                self.modelLoadView.progressView.progress = 0
                
                self.modelLoadView.progressLabel.text = "0%"
                self.modelLoadView.progressTipsLabel.text = "BIM模型加载中..."
                self.modelLoadView.progressLabel.isHidden = true
                self.modelLoadView.progressTipsLabel.isHidden = true
                self.modelLoadView.progressBgView.isHidden = true
            }
        }
        timer.fire()
    }
    
    func getLoadingLabel() {
        getLoadingMessage { [self] result in
            switch result {
            case .success(let data):
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let dict = jsonObject as? NSDictionary,
                          let arr = dict["data"] as? NSArray else {
                        self.getLoadingLabelAgin()
                        
                        return
                    }
                    
                    self.arrLoadMessage = arr
                    
                    if self.loadNumber < self.arrLoadMessage.count {
                        if let dic = self.arrLoadMessage[self.loadNumber] as? NSDictionary {
                            self.loadNumber += 1
                            
                            if self.loadNumber == self.arrLoadMessage.count {
                                self.loadStepString = "\(dic["text"] ?? "")(\(self.loadNumber)/\(self.arrLoadMessage.count))"
                            } else {
                                self.modelLoadView.stepLabel.text = "\(dic["text"] ?? "")(\(self.loadNumber)/\(self.arrLoadMessage.count))"
                            }
                        }
                    }
                    self.getLoadingLabelAgin()
                } catch {
                    self.getLoadingLabelAgin()
                }
            case .failure(let error):
                print(error)
                self.getLoadingLabelAgin()
            }
        }
    }

    func getLoadingLabelAgin() {
        if self.loadNumber >= self.arrLoadMessage.count { // 环境加载完成
            return
        }
        
        self.modelLoadView.loadLabel.isHidden = true;
        self.getLoadingLabel()
    }
    
    func addArModelLoad() {
        requestARModelLoad(request:&self.modelLoadRequest,token: car_UserInfo.tokenData,taskId: car_UserInfo.taskID, projectID: needLoadProject) {  [weak self] (result,msg) in
            if result {
                print("-----加载ar成功---")
                self?.modelLoadView.loadLabel.text = ""
                self?.modelLoadView.loadImg.isHidden = true
                self?.modelLoadView.LogImg.isHidden = true
                self?.modelLoadView.stepLabel.text = ""
                
                self?.modelLoadView.progressTipsLabel.text = "BIM模型加载中..."
                self?.modelLoadView.progressLabel.text = "0%"
                
                self?.modelLoadView.progressLabel.isHidden = false
                self?.modelLoadView.progressTipsLabel.isHidden = false
                self?.modelLoadView.progressBgView.isHidden = false
                
                self?.queryLoadProgress()
                
                WebSocketClient.shared.connect()
            } else {
                print("-----加载ar失败---\(msg)")
                self?.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: msg, screenType: .AR, project: self!.needLoadProject)
            }
        }
    }
    
    //请求模型加载
    func queryLoadModel() {
        print("query load model")
        self.modelLoadView.loadImg.isHidden = false
        self.modelLoadView.LogImg.isHidden = false
        self.modelLoadView.loadLabel.text = ""
        self.modelLoadView.stepLabel.text = ""
        loadProgress = 0.0 //重置加载进度
        
        self.modelLoadView.stepLabel.text = self.loadStepString
        requestToken(request: &tokenRequest, projectID: needLoadProject) { result in
            switch result {
            case .success(let token):
                print("token -- \(token)")
                if self.needLoadMode == .AR {
                    self.modelLoadView.loadLabel.text = "环境加载中"
                    self.arrLoadMessage = []
                    self.loadNumber = 0
                    
                    self.getLoadingLabel()
                    self.getStepFourLoadingLabel()
                    
                    self.modelLoadView.progressTipsLabel.text = "BIM模型加载中..."
                    self.modelLoadView.progressLabel.text = "0%"
                    self.modelLoadView.progressLabelLeadingConstraint.constant = 0
                    self.modelLoadView.progressBgWidthConstraint.constant = 0
                    
                    requestIPwithHostID(request: &self.modelLoadRequest, token: token, bimId: self.needLoadProject) { (result,msg) in
                        if result {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0) {
//                                        print(Thread.current)
                                self.finishBlock!(true)
                           }
                            
//                            requestExitByHostId { result in
//                                if result {
//                                    //now后面的单位是秒
//                                     DispatchQueue.main.asyncAfter(deadline: .now()+18) {
////                                        print(Thread.current)
//                                         self.finishBlock!(true)
//                                    }
//                                }else {
//                                    self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: "服务重启失败", screenType: .AR, project: self.needLoadProject)
//                                }
//                            }
                        } else {
                            self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: msg, screenType: .AR, project: self.needLoadProject)
                        }
                    }
                } else if self.needLoadMode == .ThreeD {
                    self.modelLoadView.loadLabel.text = ""
                    queryThreeDModelLoad(request: &self.modelLoadRequest, token: token, projectID: self.needLoadProject) { (result,msg) in
                        if result {
                            print("threeD model request success: url:\(car_UserInfo.threeDURL)")
                            self.loadThreeDURLProcotol?.handleLoadThreeDURL() //加载threeD url
                            
                            self.modelLoadView.loadLabel.text = ""
                            self.modelLoadView.stepLabel.text = ""
                            
                            self.queryLoadProgress()
                            WebSocketClient.shared.connect()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.modelLoadView.loadImg.isHidden = true
                                self.modelLoadView.LogImg.isHidden = true
                            }
                        } else {
                            print("threeD model request fail: \(msg)")
                            self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: msg, screenType: .ThreeD, project: self.needLoadProject)
                        }
                    }
                }
            case .failure(let error):
                print("\(#function),\(error),get token failed")
                self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: "token获取失败", screenType: .AR, project: self.needLoadProject)
            }
        }
    }
    
    // 增加记录
    func getStepFourLoadingLabel() {
        getStepFourLoadingMessage {_ in
            
        }
    }
}
