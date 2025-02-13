//
//  LoginController.swift
//  OurAR
//
//  Created by lee on 2023/7/4.
//

import Foundation
import UIKit
import CloudAR
import Alamofire
import SVProgressHUD
//import SnapKit

class LoginController: UIViewController
{
    var loginView: LoginView! //登录页
    var registerView: RegisterView! //注册页
    var forgetView: ForgetView! //忘记页
    var leftBg: UIImageView! //左边背景页
    var lblInfo:UILabel!
    var lblLogo:UILabel!
    var settingBtn: UIButton! //底部设置按钮
    
    lazy var settingController = SettingController()
    
    override func viewDidLoad() {
        self.modalPresentationStyle = .fullScreen
        let segment_start_y: CGFloat = view.bounds.height * 0.4
        let inputView_start_y: CGFloat = segment_start_y
        let right_width: CGFloat =  view.bounds.width * 0.6
        let left_width: CGFloat = view.bounds.width * 0.36
        
//        let nameImg = UIImageView(frame: CGRect(x: left_width + right_width * 0.2, y: view.bounds.height * 0.2, width: right_width * 0.3, height: 30))
////        let nameImg = UIImageView()
//        nameImg.image = UIImage(named: "OurARar")
//        nameImg.contentMode = .scaleAspectFit
//        view.addSubview(nameImg)
        
        lblLogo = UILabel(frame: CGRect(x: left_width + right_width * 0.2, y: view.bounds.height * 0.2, width: right_width * 0.3, height: 30))
        lblLogo.text = "OurAR"
        lblLogo.font = .boldSystemFont(ofSize: 25)
        view.addSubview(lblLogo)
        
        lblInfo = UILabel(frame: CGRect(x: left_width + right_width * 0.2, y: view.bounds.height * 0.2 + 40, width: right_width, height: 15))
        lblInfo.text = "欢迎使用OurBIM 云AR平台"
        lblInfo.font = .systemFont(ofSize: 12)
        lblInfo.textColor = .black.withAlphaComponent(0.8)
        view.addSubview(lblInfo)
        
        loginView = LoginView(frame: CGRect(x: 0, y: inputView_start_y, width: right_width * 0.6, height: view.bounds.height * 0.5))
        loginView.center.x = left_width + right_width * 0.5
        registerView = RegisterView(frame: CGRect(x: 0, y: inputView_start_y, width: right_width * 0.6, height: view.bounds.height * 0.5))
        registerView.center.x = left_width + right_width * 0.5
        forgetView = ForgetView(frame: CGRect(x: 0, y: inputView_start_y, width: right_width * 0.6, height: view.bounds.height * 0.5))
        forgetView.center.x  = left_width + right_width * 0.5
        // 默认进入登录页面
        view.addSubview(loginView)
        
        settingBtn = UIButton(frame: CGRect(x: view.bounds.width-50, y: view.bounds.height - 50, width: 30, height: 30))
        settingBtn.setBackgroundImage(UIImage(named: "setting"), for: .normal)
        settingBtn.contentMode = .scaleAspectFill
        settingBtn.addAction(UIAction(handler: {_ in
            // 开启设置页面
            self.settingController.modalPresentationStyle = .overFullScreen
            self.present(self.settingController, animated: true)
        }), for: .touchUpInside)
        view.addSubview(settingBtn)
        settingController.initConfig()
        // AR默认配置
//        car_URL.javaWS = ""

        if getIsIphone() {
            lblLogo.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(40)
                make.top.equalToSuperview().offset(90)
                make.height.equalTo(45)
            }
            lblInfo.snp.makeConstraints { make in
                make.top.equalTo(lblLogo.snp.bottom).offset(20)
                make.leading.equalTo(lblLogo)
                make.height.equalTo(15)
            }
            loginView.snp.makeConstraints { make in
                make.top.equalTo(lblInfo.snp.bottom).offset(30)
                make.leading.equalTo(lblLogo)
                make.trailing.equalToSuperview().offset(-30)
                make.bottom.equalToSuperview().offset(-30)
            }
            settingBtn.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-30)
                make.right.equalTo(-30)
                make.height.width.equalTo(30)
            }
        }else {
            leftBg = UIImageView(frame: CGRect(x: 0, y: 0, width: left_width, height: self.view.bounds.height))
            leftBg.image = UIImage(named: "loginleftbg")
            view.addSubview(leftBg)
        }
    }
    
    private func login(url: String) {
        self.loginView?.confirm?.isEnabled = false
        SVProgressHUD.show(withStatus: "开始登陆...")
        AF.request(url,method: .post).response { (response:AFDataResponse) in
            self.loginView?.confirm?.isEnabled = true
            switch response.result {
                case .success(let JSON):
                    do {
                        let JSONObject = try? JSONSerialization.jsonObject(with: JSON ?? Data(), options: .allowFragments)
                        if let JSON = JSONObject as? [String:Any] {
                            if let respCode = JSON["code"] as? Int,
                               let msg = JSON["message"] as? String
                            {
                                if respCode == 0
                                {
                                    if let data = JSON["data"] as? [String:Any] {
                                        
                                        //全局变量的数据设置 id ...
                                        car_UserInfo.userID = data["userid"] as? String ?? ""
                                        car_UserInfo.imgUrl = data["imgUrl"] as? String ?? ""
                                        car_UserInfo.name = data["name"] as? String ?? "匿名"
                                        
//                                        showTip(tip: "登录成功", parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_success, tipColor_text_success) {
                                        SVProgressHUD.showSuccess(withStatus: "登陆成功")
                                        print("登录成功")
                                        // 页面跳转
                                        let controller = ProjectController()
                                        controller.modalPresentationStyle = .fullScreen
                                        self.present(controller,animated: true)

//                                        }
                                    } else {
                                        SVProgressHUD.showError(withStatus: "响应数据错误")
//                                        showTip(tip: "响应数据错误", parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail,tipColor_text_fail) {}
                                    }
                                } else {
                                    SVProgressHUD.showError(withStatus: msg)
//                                    showTip(tip: msg, parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail, tipColor_text_fail) {}
                                }
                            }
                        } else {
                            SVProgressHUD.showError(withStatus: "登录响应失败")
//                            showTip(tip: "登陆响应失败", parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail, tipColor_text_fail) {}
                        }
                    }
                    break
                case .failure(let error):
                    print(error)
                    print("failure")
//                    SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "登录响应失败")
//                    showTip(tip: "登录响应失败", parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail, tipColor_text_fail) {}
            }
        }
    }
    
    func handleLogin(name: String?,password: String?) {
        var canLogin = false
        var tip: String = ""
        let nameIsEmpty = name?.count ?? 0 == 0
        let psdIsEmpty = password?.count ?? 0 == 0
        if ( nameIsEmpty && psdIsEmpty) {
            print("name or psd not init")
            tip = "用户名和密码不能为空"
        } else if (nameIsEmpty)
        {
            print("name is empty")
            tip = "用户名不能为空"
        }
        else if (psdIsEmpty)
        {
            print("psd is empty")
            tip = "密码不能为空"
        } else {
            canLogin = true
        }
        
        if !canLogin {
            showTip(tip: tip, parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail, tipColor_text_fail) {
                self.loginView?.confirm?.isEnabled = true
            }
            return
        }
        
        //从登录页面跳转到主页面
        //登录方式 1.手机号 2.邮箱
        let url = car_URL.urlPre + "UserCenter/login?loginName=\(name!)&password=\(password!)"
        //let data: [String:Any] = ["password":password!,"username":name!]
        
        UserDefaults.standard.set(name!,forKey: "username")
        UserDefaults.standard.set(password!,forKey: "password")
        print("-----login-----")
        login(url: url)
    }
    
    func handleLogin(phone: String?,code: String?) {
        loginView?.confirm?.isEnabled = false
        var canLogin = false
        var tip: String = ""
        let phoneIsEmpty = phone?.count ?? 0 == 0
        let codeIsEmpty = code?.count ?? 0 == 0
        if phoneIsEmpty && codeIsEmpty {
            tip = "手机号和验证码不能为空"
        } else if phoneIsEmpty {
            tip = "手机号不能为空"
        } else if codeIsEmpty {
            tip = "验证码不能为空"
        } else if !car_isPhone(phone!) {
            tip = "手机号格式不正确"
        } else {
            canLogin = true
        }
        if !canLogin {
            showTip(tip: tip, parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail, tipColor_text_fail) {
                self.loginView?.confirm?.isEnabled = true
            }
            return
        }
        
        // 手机验证码登录
        let url = car_URL.urlPre + "UserCenter/loginMobile?mobile=\(phone!)&code=\(code!)"
        //let data: [String:Any] = ["mobile": phone!,"code":code!]
        
        UserDefaults.standard.set(phone!,forKey: "mobile")
        
        login(url: url)
    }
    
    func handleRegister(phone: String?,registerCode: String?,password: String?,passwordAgain: String?,agree: Bool) {
        var canRegister = false
        var tip: String = ""
        let psdIsEmpty = password?.count ?? 0 == 0
        let phoneIsEmpty = phone?.count ?? 0 == 0
        let codeIsEmpty = registerCode?.count ?? 0 == 0
        let psdIsSame = password == passwordAgain
        let isPhone = psdIsEmpty ? false : car_isPhone(phone!)
        if phoneIsEmpty {
            tip = "手机号不能为空"
        } else if !isPhone {
            tip = "手机号格式错误"
        } else if psdIsEmpty {
            tip = "密码不能为空"
        } else if codeIsEmpty {
            tip = "验证码不能为空"
        } else if !psdIsSame {
            tip = "两次输入密码不一致"
        } else if !agree {
            tip = "请先同意服务协议"
        } else if password?.count ?? 0 < 6 {
            tip = "密码长度应在6位以上"
        } else {
            canRegister = true
        }
        if !canRegister {
            showTip(tip: tip, parentView: self.view, center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height*0.2),tipColor_bg_fail, tipColor_text_fail) {
            }
            return
        }
        
        self.registerView?.confirm?.isEnabled = false
        registerUser(phone: phone!, psd: password!, verificationCode: registerCode!, completion: {(isSuccess,reason) in
            self.registerView?.confirm?.isEnabled = true
            showTip(tip: reason, parentView: self.view, isSuccess ? tipColor_bg_success : tipColor_bg_fail, isSuccess ? tipColor_text_success : tipColor_text_fail, completion: {
                if isSuccess {
                    self.handleEnterPage(0,info: ["phone": phone!])
                }
            })
        })
    }
    
    func handleEnterPage(_ index: Int,info: [String:Any] = [:]) {
        //print("跳转到: \(index)")
        loginView?.removeFromSuperview()
        registerView?.removeFromSuperview()
        forgetView?.removeFromSuperview()
        switch index {
        case 0:
            //登录页
            self.view.addSubview(loginView)
            loginView.snp.makeConstraints { make in
                make.top.equalTo(lblInfo.snp.bottom).offset(30)
                make.leading.equalTo(lblLogo)
                make.trailing.bottom.equalToSuperview().offset(-30)
            }
            loginView?.enter(info: info)
            break
        case 1:
            //注册页
            self.view.addSubview(registerView)
            registerView.snp.makeConstraints { make in
                make.top.equalTo(lblInfo.snp.bottom).offset(30)
                make.leading.equalTo(lblLogo)
                make.trailing.bottom.equalToSuperview().offset(-30)
            }
            registerView?.enter(info: info)
            break
        case 2:
            //忘记密码页
            self.view.addSubview(forgetView)
            forgetView.snp.makeConstraints { make in
                make.top.equalTo(lblInfo.snp.bottom).offset(30)
                make.leading.equalTo(lblLogo)
                make.trailing.bottom.equalToSuperview().offset(-30)
            }
            forgetView?.enter(info: info)
            break
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 关闭键盘
    }
}
