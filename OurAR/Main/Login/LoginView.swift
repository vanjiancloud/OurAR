//
//  LoginView.swift
//  OurAR
//
//  Created by lee on 2023/7/4.
//

import Foundation
import UIKit
import CloudAR
import Alamofire
import WebKit

fileprivate let inputWidthRatio: CGFloat = 1.0 //input宽度占bounds宽度的比
fileprivate let inputHeight: CGFloat = 45 //input的高度
fileprivate let imgCenterX: CGFloat = 40 //input image的中心的x
fileprivate let imgSize: CGFloat = 25 //input image的大小
fileprivate let fontSize: CGFloat = 15 //input字体的大小
fileprivate let text_start_x: CGFloat = imgCenterX + imgSize / 2 + 20 //input text在view中开始的x的位置
fileprivate let input_pad_updown: CGFloat = 15 //上下两个input的间隔

//MARK: 普通输入框
fileprivate class InputView: UIView
{
   
    var img: UIImageView!
    var text: UITextField!
    
    init(frame: CGRect,_ imgCenterX: CGFloat,_ imgSize: CGFloat,_ textStartX: CGFloat,font: CGFloat,_ imgName: String,_ isSecureTextEntry: Bool = false) {
        super.init(frame: frame)
        
        //设置圆角
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1).cgColor
        self.layer.cornerRadius = bounds.height / 2
        
        img = UIImageView(frame: CGRect(x: 0, y: 0, width: imgSize, height: imgSize))
        img.center.x = imgCenterX
        img.center.y = bounds.height / 2
        img.image = UIImage(named: imgName)
        img.contentMode = .scaleAspectFit
        addSubview(img)
        
        text = UITextField(frame: CGRect(x: textStartX, y: 0, width: bounds.width - textStartX, height: bounds.height))
        text.textAlignment = .left
        text.contentMode = .left
        text.isSecureTextEntry = isSecureTextEntry
        text.font = .italicSystemFont(ofSize: font)
        text.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        text.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
        text.addTarget(self, action: #selector(editingDidEndOnExit(_:)), for: .editingDidEndOnExit)
        addSubview(text)
        
        if isSecureTextEntry {
            let show = UIButton(frame: CGRect(x: bounds.width - 35,y: 0, width: 20, height: 18))
            show.setImage(UIImage(named: "visibility"), for: .normal)
            show.center.y = bounds.height / 2
            show.contentMode = .scaleAspectFill
            show.addAction(UIAction(handler: {_ in
                if self.text.text?.count ?? 0 != 0 {
                    self.text.isSecureTextEntry = true
                }
            }), for: .touchUpInside)
            show.addAction(UIAction(handler: {_ in
                if self.text.text?.count ?? 0 != 0 {
                    self.text.isSecureTextEntry = false
                }
            }), for: .touchDown)
            addSubview(show)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editingDidBegin(_ textField: UITextField) {
        changeStyle(hasText: true)
    }
    @objc func editingDidEnd(_ textField: UITextField) {
        changeStyle(hasText: textField.text?.count ?? 0 != 0)
    }
    @objc func editingDidEndOnExit(_ textField: UITextField) {
        print("editing did end on exit")
    }
    
    func changeStyle(hasText: Bool) {
        if hasText {
            backgroundColor = .none
        } else {
            backgroundColor = VJTextColor_238
        }
        self.layer.borderWidth = hasText ? 0.5 : 0
    }
    
}

//MARK: 手机号输入框
fileprivate class PhoneView: UIView
{
    var img: UIImageView!
    var text: UITextField!
    
    init(frame: CGRect,_ imgCenterX: CGFloat,_ imgSize: CGFloat,font: CGFloat,_ imgName: String) {
        super.init(frame: frame)
        
        //设置圆角
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1).cgColor
        self.layer.cornerRadius = bounds.height / 2
        
        img = UIImageView(frame: CGRect(x: 0, y: 0, width: imgSize, height: imgSize))
        img.center.x = imgCenterX
        img.center.y = bounds.height / 2
        img.image = UIImage(named: imgName)
        img.contentMode = .scaleAspectFit
        addSubview(img)
        
        let countryCode = UILabel(frame: CGRect(x: imgCenterX + imgSize * 0.5 + 15, y: 0, width: 40, height: font))
        countryCode.center.y = bounds.height / 2
        countryCode.text = "+86 |"
        countryCode.contentMode = .left
        countryCode.textAlignment = .left
        addSubview(countryCode)
        
        let text_start_x: CGFloat = imgCenterX + imgSize * 0.5 + 15 + 40 + 15
        text = UITextField(frame: CGRect(x: text_start_x, y: 0, width: bounds.width - text_start_x, height: bounds.height))
        text.textAlignment = .left
        text.contentMode = .left
        text.font = .italicSystemFont(ofSize: font)
        text.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        text.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
        text.addTarget(self, action: #selector(editingDidEndOnExit(_:)), for: .editingDidEndOnExit)
        addSubview(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editingDidBegin(_ textField: UITextField) {
        changeStyle(hasText: true)
    }
    @objc func editingDidEnd(_ textField: UITextField) {
        changeStyle(hasText: textField.text?.count ?? 0 != 0)
    }
    @objc func editingDidEndOnExit(_ textField: UITextField) {
        print("editing did end on exit")
    }
    
    func changeStyle(hasText: Bool) {
        if hasText {
            backgroundColor = .none
        } else {
            backgroundColor = VJTextColor_238
        }
        self.layer.borderWidth = hasText ? 0.5 : 0
    }
}

//MARK: 验证码输入框
fileprivate class VerificationView: UIView
{
    var img: UIImageView!
    var text: UITextField!
    var btn: UIButton! //获取验证码
    var timer: Timer?
    var counter: Int = 60
    
    init(frame: CGRect,_ imgCenterX: CGFloat,_ imgSize: CGFloat,_ textStartX: CGFloat,font: CGFloat,_ imgName: String,_ isSecureTextEntry: Bool = false) {
        super.init(frame: frame)
    
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1).cgColor
        self.layer.cornerRadius = bounds.height / 2
        
        let btnWidth: CGFloat = 7 * font
        
        img = UIImageView(frame: CGRect(x: 0, y: 0, width: imgSize, height: imgSize))
        img.center.x = imgCenterX
        img.center.y = bounds.height / 2
        img.image = UIImage(named: imgName)
        img.contentMode = .scaleAspectFit
        addSubview(img)
        
        text = UITextField(frame: CGRect(x: textStartX, y: 0, width: bounds.width - textStartX - btnWidth, height: bounds.height))
        text.textAlignment = .left
        text.contentMode = .left
        text.isSecureTextEntry = isSecureTextEntry
        text.font = .italicSystemFont(ofSize: font)
        text.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        text.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
        text.addTarget(self, action: #selector(editingDidEndOnExit(_:)), for: .editingDidEndOnExit)
        addSubview(text)
        
        btn = UIButton(frame: CGRect(x: bounds.width - btnWidth, y: 0, width: btnWidth, height: bounds.height * 0.8))
        btn.center.y = bounds.height / 2
        btn.contentMode = .center
        btn.setTitleColor(VJConfirmColor, for: .normal)
        btn.setTitle("获取验证码", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: font)
        btn.titleLabel?.textAlignment = .center
        addSubview(btn)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editingDidBegin(_ textField: UITextField) {
        changeStyle(hasText: true)
    }
    @objc func editingDidEnd(_ textField: UITextField) {
        changeStyle(hasText: textField.text?.count ?? 0 != 0)
    }
    @objc func editingDidEndOnExit(_ textField: UITextField) {
        print("editing did end on exit")
    }
    
    func changeStyle(hasText: Bool) {
        if hasText {
            backgroundColor = .none
        } else {
            backgroundColor = VJTextColor_238
        }
        self.layer.borderWidth = hasText ? 0.5 : 0
    }
    
    // 倒计时
    func countDown(_ start: Bool) {
        timer?.invalidate()
        counter = 60
        self.btn?.isEnabled = true
        if start {
            self.btn?.isEnabled = false
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
                if self.counter > 0 {
                    self.counter -= 1
                    self.btn?.titleLabel?.text = "\(self.counter)s后继续"
                } else {
                    timer.invalidate()
                    self.btn?.titleLabel?.text = "获取验证码"
                    self.btn?.isEnabled = true
                }
            }
        }
    }
}

//MARK: 同意条约
fileprivate class AgreeProcotolView: UIView
{
    private var btn: UIButton!
    private var label: UILabel!
    private var procotolBtn: UIButton!
    var agree: Bool {
        didSet {
            self.btn.setBackgroundImage(UIImage(named: self.agree ? "remenbercheck" : "remenberuncheck"), for: .normal)
        }
    }
    
    init(frame: CGRect,btnSize: CGFloat) {
        self.agree = false
        super.init(frame: frame)
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        btn.center.y = bounds.height / 2
        btn.setBackgroundImage(UIImage(named: self.agree ? "remenbercheck" : "remenberuncheck"), for: .normal)
        btn.addAction(UIAction(handler: {_ in
            self.agree = !self.agree
        }), for: .touchUpInside)
        addSubview(btn)
        
        label = UILabel()
        label.text = "我同意"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        addSubview(label)
        
        procotolBtn = UIButton()
        procotolBtn.setTitle("《OurAR用户服务协议》", for: .normal)
        procotolBtn.setTitleColor(VJConfirmColor, for: .normal)
        procotolBtn.titleLabel?.textAlignment = .left
        procotolBtn.addAction(UIAction(handler: {_ in
            // 弹出协议条框
            if let currentC = getControllerOfSubview(self) {
                let controller = UIViewController()
                let webConfiguration = WKWebViewConfiguration()
                let webView = WKWebView(frame: .zero, configuration: webConfiguration)
                controller.view.addSubview(webView)
                webView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: controller.view.topAnchor),
                    webView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
                    webView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                    webView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor)
                ])
                currentC.present(controller, animated: true)
                if let url = URL(string: "https://www.OurBim.com/project_center/#/protocol") {
                    let request = URLRequest(url: url)
                    webView.load(request)
                }
            }
        }),for: .touchUpInside)
        addSubview(procotolBtn)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: btn.rightAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        procotolBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            procotolBtn.leftAnchor.constraint(equalTo: label.rightAnchor,constant: 0),
            procotolBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 5),
            procotolBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LoginView: UIView
{
    // 账号登录
    private var name: InputView!
    private var psd: InputView!
    // 短信登录
    private var phone: PhoneView!
    private var verification: VerificationView!
    
    var confirm: UIButton!
    var remenberBtn: UIButton!
    var remenberLabel: UILabel!
    var toRegister: UIButton!
    var toForget: UIButton!
    var segmented: UISegmentedControl!
    
    private func changeAllTextStyle() {
        name?.changeStyle(hasText: name.text.text?.count ?? 0 != 0)
        psd?.changeStyle(hasText: psd.text.text?.count ?? 0 != 0)
        phone?.changeStyle(hasText: phone.text.text?.count ?? 0 != 0)
        verification?.changeStyle(hasText: verification.text.text?.count ?? 0 != 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .white
        initSubview()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initSubview() {
        let inputWidth: CGFloat = bounds.width * inputWidthRatio
        let inputHeight: CGFloat = inputHeight
        let imgCenter: CGFloat = imgCenterX
        let imgSize: CGFloat = imgSize
        let textStartX: CGFloat = text_start_x
        let font: CGFloat = 15
        
        let segments = ["账号登录","短信登录"]
        segmented = createUnderlinedSegmentedView(items: segments)
        segmented.selectedSegmentIndex = 0
        segmented.frame = CGRect(x: 0, y: 0, width: inputWidth * 0.65, height: 35)
        segmented.center.x = bounds.width / 2
        segmented.addTarget(self, action: #selector(self.segmentChang(_:)), for: .valueChanged)
        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: VJTextColor_07,.font: UIFont.systemFont(ofSize: 14)
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: VJConfirmColor,.font: UIFont.systemFont(ofSize: 18)
        ]
        segmented.setTitleTextAttributes(normalAttr, for: .normal)
        segmented.setTitleTextAttributes(selectedAttr, for: .selected)
       
        addSubview(segmented)
        
        let pad_seg: CGFloat = 70
        
        name = InputView(frame: CGRect(x: 0, y: pad_seg, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "user")
        name?.text.placeholder = "账号"
        addSubview(name)
        
        psd = InputView(frame: CGRect(x: 0, y: (inputHeight + input_pad_updown) * 1 + pad_seg, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "secure",true)
        psd?.text.placeholder = "密码"
        addSubview(psd)
        
        phone = PhoneView(frame: CGRect(x: 0, y: pad_seg, width: inputWidth, height: inputHeight), imgCenter, imgSize, font: font, "phone")
        phone?.text.placeholder = "手机号码"
        addSubview(phone)
        phone.isHidden = true
        
        verification = VerificationView(frame: CGRect(x: 0, y: (inputHeight + input_pad_updown) * 1 + pad_seg, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "message")
        verification?.text.placeholder = "验证码"
        verification.btn.addAction(UIAction(handler: {_ in
            // 短信验证码
            if let phone = self.phone.text.text,
               !phone.isEmpty {
                if car_isPhone(phone) {
                    phoneIsExist(phone: phone, completion: {(isSuccess,reason) in
                        if isSuccess {
                            sendVerificationCode(phone: phone, type: .login, completion: {(isSuccess,msg) in
                                if isSuccess {
                                    self.verification?.countDown(true)
                                    showTip(tip: "获取成功", parentView: self.superview ?? self, tipColor_bg_success, tipColor_text_success, completion: {})
                                } else {
                                    showTip(tip: msg, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                                }
                            })
                        } else {
                            showTip(tip: reason, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                        }
                    })
                } else {
                    showTip(tip: "手机号格式不正确", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                }
            } else {
                showTip(tip: "请输入手机号", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
            }
        }), for: .touchUpInside)
        addSubview(verification)
        verification.isHidden = true
        
        
        let labelWidth: CGFloat = 5 * 14
        let pad_psd: CGFloat = 11 //距psd的距离
        let remenberY: CGFloat = psd.center.y + psd.bounds.height/2 + pad_psd
        let remenberHeight: CGFloat = 20
        let reLabelX: CGFloat = remenberHeight
        let reBtnX: CGFloat = 0
        remenberLabel = UILabel(frame: CGRect(x: reLabelX , y: remenberY, width: labelWidth, height: remenberHeight))
        remenberLabel.text = "记住密码"
        remenberLabel.textColor = .black
        remenberLabel.font = .systemFont(ofSize: 16)
        remenberLabel.textAlignment = .right
        addSubview(remenberLabel)
        
        remenberBtn = UIButton(frame: CGRect(x:reBtnX , y: remenberY, width: remenberHeight, height: remenberHeight))
        remenberBtn.contentMode = .scaleAspectFit
        remenberBtn.addAction(UIAction(handler: {_ in
            self.changeRemenber()
        }),for: .touchUpInside)
        addSubview(remenberBtn)
        
        toForget = UIButton(frame: CGRect(x: bounds.width - 5*font, y: remenberY, width: 5*font, height: remenberHeight))
        toForget.setTitle("忘记密码?", for: .normal)
        toForget.titleLabel?.textAlignment = .right
        toForget.setTitleColor(VJConfirmColor, for: .normal)
        toForget.titleLabel?.font = .systemFont(ofSize: font)
        toForget.addAction(UIAction(handler: {_ in
            // 跳转到忘记密码页面
            if let loginC = getControllerOfSubview(self) as? LoginController {
                loginC.handleEnterPage(2)
            }
        }), for: .touchUpInside)
        addSubview(toForget)
        
        toRegister = UIButton(frame: CGRect(x: bounds.width - 5*font - 7*font, y: remenberY, width: 6 * font, height: remenberHeight))
        toRegister.setTitle("注册新用户", for: .normal)
        toRegister.titleLabel?.textAlignment = .left
        toRegister.setTitleColor(VJConfirmColor, for: .normal)
        toRegister.titleLabel?.font = .systemFont(ofSize: font)
        toRegister.addAction(UIAction(handler: {_ in
            // 跳转到注册页面
            if let loginC = getControllerOfSubview(self) as? LoginController {
                loginC.handleEnterPage(1)
            }
        }), for: .touchUpInside)
        addSubview(toRegister)
        
        confirm = UIButton(frame: CGRect(x: 0, y: (inputHeight + input_pad_updown) * 2 + pad_seg + 50 , width: inputWidth, height: inputHeight))
        confirm.backgroundColor = VJConfirmColor
        confirm.layer.cornerRadius = inputHeight / 2
        confirm.setTitle("登 录", for: .normal)
        confirm.setTitleColor(.white, for: .normal)
        confirm.addAction(UIAction(handler: {_ in
            if let loginController = getControllerOfSubview(self) as? LoginController {
                self.segmented.selectedSegmentIndex == 0
                ?
                loginController.handleLogin(name: self.name?.text?.text, password: self.psd.text?.text)
                :
                loginController.handleLogin(phone: self.phone.text.text, code: self.verification.text.text)
            } else {
                print("login controller is not login view's next")
            }
        }), for: .touchUpInside)
        addSubview(confirm)
        
        //username psd remenber 的默认值
        if let username = UserDefaults.standard.string(forKey: "username") {
            name.text!.text = username
        }
        var remberBgName = "remenberuncheck"
        let isRemenber = UserDefaults.standard.bool(forKey: "remenber")
        if isRemenber == true {
            if let password = UserDefaults.standard.string(forKey: "password") {
                psd.text!.text = password
            }
        }
        remberBgName = isRemenber ? "remenbercheck" : "remenberuncheck"
        remenberBtn.setBackgroundImage(UIImage(named: remberBgName), for: .normal)
        
        // 改变所有input的样式
        changeAllTextStyle()
    }
    
    private func changeRemenber() {
        let isRemenber = UserDefaults.standard.bool(forKey: "remenber")
        UserDefaults.standard.set(!isRemenber, forKey: "remenber")
        remenberBtn?.setBackgroundImage(UIImage(named: !isRemenber ? "remenbercheck" : "remenberuncheck"), for: .normal)
    }
    
    private func showPasswordLoginOrMessage(showPassword: Bool) {
        remenberBtn?.isHidden = !showPassword
        remenberLabel?.isHidden = !showPassword
        
        name?.isHidden = !showPassword
        psd?.isHidden = !showPassword
        psd?.text.isSecureTextEntry = true
        
        phone?.isHidden = showPassword
        verification?.isHidden = showPassword
    }
    
    func enter(info: [String:Any] = [:]) {
        name?.text.text = info["phone"] as? String ?? ""
        psd?.text.text = ""
        phone?.text.text = ""
        verification?.text.text = ""
        confirm?.isEnabled = true
        segmented?.selectedSegmentIndex = 0
        
        showPasswordLoginOrMessage(showPassword: true)
        
        changeAllTextStyle()
    }
    
    @objc private func segmentChang(_ sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            
            name?.text.text = ""
            psd?.text.text = ""
            phone?.text.text = ""
            verification?.text.text = ""
            verification?.countDown(false)
            
            switch segment.selectedSegmentIndex {
            case 0:
                showPasswordLoginOrMessage(showPassword: true)
                break
            case 1:
                showPasswordLoginOrMessage(showPassword: false)
                break
            default:
                break
            }
            
            changeAllTextStyle()
        }
    }
}


class RegisterView: UIView
{
    private var phone: PhoneView!
    private var verification: VerificationView!
    private var psd: InputView!
    private var psdAgain: InputView!
    private var agree: AgreeProcotolView! //同意隐私政策
    var confirm: UIButton! //确定注册
    var toLogin: UIButton! //返回登录
    
    private func changeAllTextStyle() {
        psdAgain?.changeStyle(hasText: psdAgain.text.text?.count ?? 0 != 0)
        psd?.changeStyle(hasText: psd.text.text?.count ?? 0 != 0)
        phone?.changeStyle(hasText: phone.text.text?.count ?? 0 != 0)
        verification?.changeStyle(hasText: verification.text.text?.count ?? 0 != 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubview()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initSubview() {
        let input_start_x: CGFloat = bounds.width * (1 - inputWidthRatio) / 2
        let inputWidth: CGFloat = bounds.width * inputWidthRatio
        let inputHeight: CGFloat = inputHeight
        let imgCenter: CGFloat = imgCenterX
        let imgSize: CGFloat = imgSize
        let textStartX: CGFloat = text_start_x
        let font: CGFloat = 15
        
        phone = PhoneView(frame: CGRect(x: input_start_x, y: 0, width: inputWidth, height: inputHeight), imgCenter, imgSize, font: font,"phone")
        phone?.text.placeholder = "手机号码"
        addSubview(phone)
        
        verification = VerificationView(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 1, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "message")
        verification.btn.addAction(UIAction(handler: {_ in
            // 获取验证码
            if let phone = self.phone.text.text,!phone.isEmpty
            {
                if car_isPhone(phone) {
                    // 判断手机号是否不存在
                    phoneNotExist(phone: phone, completion: {(isSuccess,msg) in
                        if isSuccess {
                            sendVerificationCode(phone:phone, type: .register) { (isSuccess,reason) in
                                if isSuccess {
                                    self.verification.countDown(true)
                                    showTip(tip: "获取成功", parentView: self.superview ?? self, tipColor_bg_success, tipColor_text_success, completion: {})
                                } else {
                                    showTip(tip: reason, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                                }
                            }
                        } else {
                            showTip(tip: msg, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                        }
                    })
                } else {
                    showTip(tip: "手机号格式不正确", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                }
            } else {
                showTip(tip: "请输入手机号", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
            }
            
        }), for: .touchUpInside)
        verification?.text.placeholder = "验证码"
        addSubview(verification)
        
        psd = InputView(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 2, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "secure",true)
        psd?.text.placeholder = "密码"
        addSubview(psd)
        
        psdAgain = InputView(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 3, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "secure",true)
        psdAgain?.text.placeholder = "再次输入密码"
        addSubview(psdAgain)
        
        agree = AgreeProcotolView(frame: CGRect(x: 0, y: (inputHeight + input_pad_updown) * 4, width: bounds.width * 0.8, height: 20), btnSize: 20)
        addSubview(agree)
        
        confirm = UIButton(frame: CGRect(x: 0, y: (inputHeight + input_pad_updown) * 4 + 50, width: inputWidth, height: inputHeight))
        confirm.backgroundColor = VJConfirmColor
        confirm.layer.cornerRadius = inputHeight / 2
        confirm.setTitle("注 册", for: .normal)
        confirm.setTitleColor(.white, for: .normal)
        confirm.addAction(UIAction(handler: {_ in
            if let loginController = getControllerOfSubview(self) as? LoginController {
                self.confirm.isEnabled = false
                loginController.handleRegister(phone: self.phone.text.text, registerCode: self.verification.text.text, password: self.psd.text.text, passwordAgain: self.psdAgain.text.text, agree: self.agree.agree)
            } else {
                print("login controller is not register view")
            }
        }), for: .touchUpInside)
        addSubview(confirm)
        
        toLogin = UIButton(frame: CGRect(x: 0, y: confirm.center.y + confirm.bounds.height / 2 + input_pad_updown, width: inputWidth, height: 20))
        toLogin.center.x = bounds.width / 2
        toLogin.setTitle("已有账号？返回登录", for: .normal)
        toLogin.setTitleColor(VJConfirmColor, for: .normal)
        toLogin.contentMode = .center
        toLogin.titleLabel?.textAlignment = .center
        toLogin.titleLabel?.font = .systemFont(ofSize: 18)
        toLogin.addAction(UIAction(handler: {_ in
            if let loginC = getControllerOfSubview(self) as? LoginController {
                loginC.handleEnterPage(0)
            }
        }),for: .touchUpInside)
        addSubview(toLogin)
        
        changeAllTextStyle()
    }
    
    func enter(info: [String:Any] = [:]) {
        phone?.text.text = ""
        psd?.text.text = ""
        verification?.text.text = ""
        verification?.countDown(false)
        agree?.agree = false
        psd?.text.isSecureTextEntry = true
        psdAgain?.text.isSecureTextEntry = true
        
        changeAllTextStyle()
    }
}
 
class ForgetView: UIView
{
    private var label: UILabel!
    // 获取验证码
    private var phone: PhoneView!
    private var verification: VerificationView!
    private var nextStep: UIButton! //下一步
    
    // 新密码
    private var psd: InputView!
    private var psdAgain: InputView!
    private var confirm: UIButton! //确定修改密码
    
    // toLogin
    private var toLogin: UIButton! //返回登录
    
    private func changeAllTextStyle() {
        psdAgain?.changeStyle(hasText: psdAgain.text.text?.count ?? 0 != 0)
        psd?.changeStyle(hasText: psd.text.text?.count ?? 0 != 0)
        phone?.changeStyle(hasText: phone.text.text?.count ?? 0 != 0)
        verification?.changeStyle(hasText: verification.text.text?.count ?? 0 != 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let input_start_x: CGFloat = bounds.width * (1 - inputWidthRatio) / 2
        let inputWidth: CGFloat = bounds.width * inputWidthRatio
        let inputHeight: CGFloat = inputHeight
        let imgCenter: CGFloat = imgCenterX
        let imgSize: CGFloat = imgSize
        let textStartX: CGFloat = text_start_x
        let font: CGFloat = 15
        
        let label_pad: CGFloat = 70
        
        label = UILabel()
        label.text = "重置密码"
        label.textColor = VJTextColor_07
        label.font = .systemFont(ofSize: 24)
        addSubview(label)
        
        phone = PhoneView(frame: CGRect(x: input_start_x, y:(inputHeight + input_pad_updown) * 0 + label_pad , width: inputWidth, height: inputHeight), imgCenter, imgSize, font: font, "phone")
        phone.text.placeholder = "手机号码"
        addSubview(phone)
        
        verification = VerificationView(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 1 + label_pad, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "message")
        verification.btn.addAction(UIAction(handler: {_ in
            // 获取重置验证码
            if let phone = self.phone.text.text,!phone.isEmpty
            {
                if car_isPhone(phone) {
                    // 判断手机号是否不存在
                    phoneIsExist(phone: phone, completion: {(isSuccess,msg) in
                        if isSuccess {
                            sendVerificationCode(phone:phone, type: .changePSD) { (isSuccess,reason) in
                                if isSuccess {
                                    self.verification.countDown(true)
                                    showTip(tip: "获取成功", parentView: self.superview ?? self, tipColor_bg_success, tipColor_text_success, completion: {})
                                } else {
                                    showTip(tip: reason, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                                }
                            }
                        } else {
                            showTip(tip: msg, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                        }
                    })
                } else {
                    showTip(tip: "手机号格式不正确", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                }
            } else {
                showTip(tip: "请输入手机号", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
            }
        }), for: .touchUpInside)
        verification.text.placeholder = "验证码"
        addSubview(verification)
        
        nextStep = UIButton(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 2 + label_pad + 35, width: inputWidth, height: inputHeight))
        nextStep.backgroundColor = VJConfirmColor
        nextStep.layer.cornerRadius = inputHeight / 2
        nextStep.setTitle("下一步", for: .normal)
        nextStep.setTitleColor(.white, for: .normal)
        nextStep.addAction(UIAction(handler: {_ in
            if let phone = self.phone.text.text,let code = self.verification.text.text {
                if phone.isEmpty || code.isEmpty {
                    showTip(tip: "手机号或验证码不能为空", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                } else if !car_isPhone(phone) {
                    showTip(tip: "手机号格式不正确", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                } else {
                    sendVerificationCode(phone: phone, type: .changePSD, completion: {(isSuccess,reason) in
                        if isSuccess {
                            // 进入到设置新密码页
                            self.phone?.removeFromSuperview()
                            self.verification?.removeFromSuperview()
                            self.nextStep?.removeFromSuperview()
                            self.addSubview(self.psd)
                            self.addSubview(self.psdAgain)
                            self.addSubview(self.confirm)
                            self.psd?.text.text = ""
                            self.psdAgain?.text.text = ""
                            self.psd?.text.isSecureTextEntry = true
                            self.psdAgain?.text.isSecureTextEntry = true
                        } else {
                            showTip(tip: reason, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                        }
                    })
                }
            }
        }), for: .touchUpInside)
        addSubview(nextStep)
        
        psd = InputView(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 0 + label_pad, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "secure",true)
        psd.text.placeholder = "新密码"
        psdAgain = InputView(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 1 + label_pad, width: inputWidth, height: inputHeight), imgCenter, imgSize, textStartX, font: font, "secure")
        psdAgain.text.placeholder = "再次输入新密码"
        confirm = UIButton(frame: CGRect(x: input_start_x, y: (inputHeight + input_pad_updown) * 2 + label_pad + 35, width: inputWidth, height: inputHeight))
        confirm.backgroundColor = VJConfirmColor
        confirm.layer.cornerRadius = inputHeight / 2
        confirm.setTitle("下一步", for: .normal)
        confirm.setTitleColor(.white, for: .normal)
        confirm.addAction(UIAction(handler: {_ in
            // 确认修改新密码
            if let psd = self.psd.text.text,let psdAgain = self.psdAgain.text.text {
                if psd.isEmpty && psdAgain.isEmpty {
                    showTip(tip: "密码不能为空", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                } else if psd.isEmpty || psdAgain.isEmpty || psd != psdAgain {
                    showTip(tip: "前后密码不一致", parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                } else {
                    if let phone = self.phone.text.text,let code = self.verification.text.text {
                        resetPassword(phone: phone, psd: psd, verificationCode: code, completion: {(isSuccess,reason) in
                            if isSuccess {
                                self.toLogin.isEnabled = false
                                showTip(tip: "重置成功，即将返回登录页", parentView: self.superview ?? self, tipColor_bg_success, tipColor_text_success, completion: {
                                    self.toLogin.isEnabled = true
                                    if let loginC = getControllerOfSubview(self) as? LoginController {
                                        loginC.handleEnterPage(0,info: ["phone": phone])
                                    }
                                })
                            } else {
                                showTip(tip: reason, parentView: self.superview ?? self, tipColor_bg_fail, tipColor_text_fail, completion: {})
                            }
                        })
                    } else {
                        print("reset password error,lost phone or code")
                    }
                }
            }
        }), for: .touchUpInside)
        
        toLogin = UIButton(frame: CGRect(x: 0, y: nextStep.center.y + nextStep.bounds.height / 2 + input_pad_updown, width: inputWidth, height: 20))
        toLogin.center.x = bounds.width / 2
        toLogin.setTitle("想起了密码？返回登录", for: .normal)
        toLogin.setTitleColor(VJConfirmColor, for: .normal)
        toLogin.contentMode = .center
        toLogin.titleLabel?.textAlignment = .center
        toLogin.titleLabel?.font = .systemFont(ofSize: 18)
        toLogin.addAction(UIAction(handler: {_ in
            if let loginC = getControllerOfSubview(self) as? LoginController {
                loginC.handleEnterPage(0)
            }
        }),for: .touchUpInside)
        addSubview(toLogin)
        
        // 添加约束
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        changeAllTextStyle()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enter(info: [String:Any]) {
        addSubview(phone)
        addSubview(verification)
        addSubview(nextStep)
        psd?.removeFromSuperview()
        psdAgain?.removeFromSuperview()
        confirm?.removeFromSuperview()
        phone?.text.text = ""
        verification?.text.text = ""
        verification?.countDown(false)
        changeAllTextStyle()
    }
}
