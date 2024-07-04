//
//  ScreenTool.swift
//  OurAR
//
//  Created by lee on 2023/6/2.
//  Copyright © 2023 NVIDIA. All rights reserved.
//
import UIKit
import Foundation
import CloudAR

// exit btn
class BackBtnView: UIView
{
    var btn: UIButton!
    var img: UIImageView!
    init(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = VJViewBGColor
        
        self.layer.mask = makeMask(8,self.bounds,[.topRight,.bottomRight])
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        addSubview(btn)
        
        img = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        img.image = UIImage(named: "backbg")
        img.contentMode = .scaleAspectFit
        img.center = CGPoint(x: width/2,y: height/2)
        addSubview(img)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CloseButtn: UIButton
{
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setBackgroundImage(UIImage(named: "close"), for: .normal)
        self.contentMode = .scaleToFill
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// 进入定位view
class EnterPositionView: UIView
{
    var btn: UIButton!

    init(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = VJViewBGColor
        
        self.layer.mask = makeMask(8,self.bounds,[.bottomLeft,.bottomRight,.topLeft,.topRight])
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: width * 0.8, height: height * 0.8))
        btn.setBackgroundImage(UIImage(named: "enterposition"), for: .normal)
        btn.contentMode = .scaleAspectFill
        btn.center = CGPoint(x: width / 2, y: height / 2)
        btn.addAction(UIAction(handler: {_ in
            EPDelegateManager.notity()
        }), for: .touchUpInside)
        addSubview(btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SliderView:UISlider
{
    init(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 切换模式view
class SwitchModeView: UIView
{
    var threeDLabel: UILabel!   //3d
    var arLabel: UILabel!       //ar
    var btnSwitch: UIButton!    //switch
    
    //width height 固定
    let width: CGFloat = 45
    let height: CGFloat = 115
    
    init(x: CGFloat,y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor(white: 1, alpha: 0.5)
        layer.cornerRadius = 5
        clipsToBounds = true
        initSubView()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func changeSwitchBG(toScreenMode: car_ScreenMode)
    {
        let switchImgName = toScreenMode == .AR ? "switchOn" : "switchOff"
        let switchImg = UIImage(named: switchImgName)
        btnSwitch?.setImage(switchImg, for: .normal)
    }
    
    func initSubView()
    {
        backgroundColor = VJViewBGColor
        arLabel = UILabel(frame: CGRect(x: 0, y: 8, width: width, height: 15))
        arLabel.font = UIFont.systemFont(ofSize: 16)
        arLabel.text = "AR"
        arLabel.textColor = .white
        arLabel.textAlignment = .center
        
        btnSwitch = UIButton(frame: CGRect(x: 0, y: 28, width: width, height: height - 59))
        btnSwitch.setTitle("", for: .normal)
        btnSwitch.contentMode = .scaleToFill
        btnSwitch.addTarget(self, action: #selector(switchMode), for: .touchDown)
        changeSwitchBG(toScreenMode: car_EngineStatus.screenMode)
        
        threeDLabel = UILabel(frame: CGRect(x: 0, y: height - 23, width: width, height: 15))
        threeDLabel.font = UIFont.systemFont(ofSize: 16)
        threeDLabel.text = "3D"
        threeDLabel.textColor = .white
        threeDLabel.textAlignment = .center
        
        
        addSubview(btnSwitch)
        addSubview(threeDLabel)
        addSubview(arLabel)
        
    }
    
    // 3D <---> AR
    @objc private func switchMode(sender: UIButton)
    {
        let toScreenMode = car_EngineStatus.screenMode == car_ScreenMode.AR ? car_ScreenMode.ThreeD : car_ScreenMode.AR
        
        SSMDelegateManager.notity(toScreenMode: toScreenMode)
        
        //进入扫码还是进入3D模式
    }
}

//MARK: 主菜单底部工具按钮
class MainToolBtn: UIView
{
    var btn: UIButton!
    var label: UILabel!
    
    var width: CGFloat = 30.0
    var height: CGFloat = 30.0
    var labelFont: CGFloat = 0
    var toolType: MainToolType!
    
    var normalImg: UIImage?
    var highlightImg: UIImage?
    
    init(width: CGFloat, height: CGFloat,labelFont: CGFloat,type: MainToolType) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.width = width
        self.height = height
        self.labelFont = showLable() ? labelFont : 0
        self.toolType = type
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: height-labelFont, height: height-labelFont))
    
        normalImg = UIImage(named: getMainToolImgName(toolType) ?? "")
        if normalImg != nil {
            highlightImg = normalImg?.withTintColor(btnHighlightColor, renderingMode: .alwaysOriginal)
            btn.setBackgroundImage(normalImg!,for: .normal)
        } else {
            btn.setTitle("no", for: .normal)
        }
        
        btn.contentMode = .scaleToFill
        btn.center.x = frame.width / 2
        if !showLable() {
            btn.center.y = frame.height / 2
        }
        btn.addAction(UIAction(handler: { _ in
            VJMTDelegateManager.notity(mainType: self.toolType!)
        }), for: .touchUpInside)
        addSubview(btn)
        
        if showLable() {
            label = UILabel(frame: CGRect(x: 0, y: height-labelFont, width: width, height: labelFont))
            label.font = .boldSystemFont(ofSize: labelFont)
            label.contentMode = .center
            label.textAlignment = .center
            label.text = getMainToollabName(toolType) ?? ""
            label.textColor = .white
            addSubview(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func highlight(_ Is: Bool = true) {
        if normalImg != nil && highlightImg != nil {
            btn?.setBackgroundImage(Is ? highlightImg! : normalImg!, for: .normal)
        }
    }
    
    private func showLable() ->Bool {
        return car_EngineStatus.showTextOfMainTool
    }
}

//MARK: 主菜单底部工具栏
class MainToolView: UIView
{
    var tools: [MainToolType: MainToolBtn] = [:]
    
    var width: CGFloat = 100.0
    let height: CGFloat = 65.0
    
    let spacing: CGFloat = 0.0    //horizontalView's spacing
    
    let btnWidthRatio: CGFloat = 0.8
    let btnheightRatio: CGFloat = 0.8
    
    let left_right_space: CGFloat = 20
    let labelFont: CGFloat = 12
    
    init(x: CGFloat,y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        initTools()
        initSubview()
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        //设置圆角
        self.layer.cornerRadius = height * 0.18
        self.layer.borderWidth = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initTools()
    {
        for (toolType,_) in car_EngineStatus.mainToolsInfo.info {
            if tools.index(forKey: toolType) == nil {
                let toolBtn = MainToolBtn(width: height * btnWidthRatio , height: height * btnheightRatio,labelFont: labelFont, type: toolType)
                tools[toolType] = toolBtn
            }
        }
    }
    
    private func initSubview()
    {
    }
    
    private func removeAllBtn()
    {
        for (_,btn) in tools {
            btn.removeFromSuperview()
        }
    }
    
    //MARK: 重置当前所展示的Tool
    func resetFrame() -> Float
    {
        removeAllBtn()
        
        let mode = car_EngineStatus.screenMode
        var needShowTools: [MainToolBtn] = []
        
        // 规范maintool的展示顺序
        for toolType in getMainToolsByOrder() {
            if validOfScreenModeAndToolType(mode, toolType) {
                if let btn = tools[toolType] {
                    needShowTools.append(btn)
                }
            }
        }
        
        let count: CGFloat = CGFloat(needShowTools.count)
        width = count * height + left_right_space + (count - 1) * spacing //btn的长度+horizontal左右两边间距+btn之间的间距
        
        var viewFrame = self.frame
        viewFrame.size.width = width
        self.frame = viewFrame
        
        if let superview = self.superview {
            self.center.x = superview.frame.width / 2
        } else {
            self.center.x = UIScreen.main.bounds.width / 2
        }
        
        var i: Int = 0
        for btn in needShowTools {
            var btnFrame = btn.frame
            btnFrame.origin.x = CGFloat(i) * (height + spacing) + left_right_space / 2 + height * (1 - btnWidthRatio) / 2
            btnFrame.origin.y = height * (1 - btnheightRatio) * 0.5
            btn.frame = btnFrame
            addSubview(btn)
            i = i + 1
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        return Float(width)
    }
    
    //MARK: 取消所有tool btn的高亮
    func cancelHighLightAll() {
        for (_,btn) in tools {
            btn.highlight(false)
        }
    }
    //MARK: 是否高亮某一个btn
    func highlightTool(_ type: MainToolType,Is: Bool = true) {
        tools[type]?.highlight(Is)
    }
}


//MARK: 子工具按钮
class SecondToolBtn: UIView
{
    var btn: UIButton!
    var label: UILabel!
    
    var width: CGFloat = 30.0
    var height: CGFloat = 30.0
    var labelFont: CGFloat = 15.0
    var mainType: MainToolType!
    var type: SecondToolType!
    
    var normalImg: UIImage?
    var highlightImg: UIImage?
    
    init(_ width: CGFloat,_ height: CGFloat,_ labelFont: CGFloat,_ type: SecondToolType,_ mainType: MainToolType) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.width = width
        self.height = height
        self.labelFont = showLable() ? labelFont : 0
        self.type = type
        self.mainType = mainType
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: height - labelFont, height: height - labelFont))
        
        normalImg = UIImage(named: getSecondToolImgName(mainType, type) ?? "")
        if normalImg != nil {
            highlightImg = normalImg?.withTintColor(btnHighlightColor, renderingMode: .alwaysOriginal)
            btn.setBackgroundImage(normalImg, for: .normal)
        } else {
            btn.setTitle("no", for: .normal)
        }
        
        btn.contentMode = .scaleToFill
        btn.center.x = frame.width / 2
        if !showLable() {
            btn.center.y = frame.height / 2
        }
        btn.addAction(UIAction(handler: { _ in
            VJMTDelegateManager.notity(mainType:self.mainType!,secondType: self.type!)
        }), for: .touchUpInside)
        addSubview(btn)
        
        if showLable() {
            label = UILabel(frame: CGRect(x: 0, y: height-labelFont, width: width, height: labelFont))
            label.font = .boldSystemFont(ofSize: labelFont)
            label.contentMode = .center
            label.textAlignment = .center
            label.text = getSecondToollabName(mainType, type) ?? ""
            label.textColor = .white
            addSubview(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func highlight(_ Is: Bool = true) {
        if normalImg != nil && highlightImg != nil {
            btn?.setBackgroundImage(Is ? highlightImg! : normalImg!, for: .normal)
        }
    }
    
    private func showLable() ->Bool {
        return car_EngineStatus.showTextOfMainTool
    }
}

//MARK: 子菜单工具栏
class SecondToolView: UIView
{
    var mainType: MainToolType!
    var tools: [SecondToolType: SecondToolBtn] = [:]
    
    var width: CGFloat = 100.0
    let height: CGFloat = 50.0
    
    let spacing: CGFloat = 5.0    //horizontalView's spacing
    
    let btnWidthRatio: CGFloat = 0.8
    let btnheightRatio: CGFloat = 0.8
    
    let left_right_space: CGFloat = 10
    let labelFont: CGFloat = 0 //没有label
    
    init(mainType: MainToolType) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        //设置圆角
        self.layer.cornerRadius = height * 0.18
        self.layer.borderWidth = 0
        self.mainType = mainType
        
        initTools()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func removeAllBtn() {
        for (_,btn) in tools {
            btn.removeFromSuperview()
        }
    }
    
    func initTools() {
        cancelhighlightAll()
        removeAllBtn()
        tools.removeAll()
        
        if let SecondToolsInfo = car_EngineStatus.mainToolsInfo.info[mainType]?.secondTools,
           let mType = self.mainType
        {
            for (type,_) in SecondToolsInfo {
                if tools.index(forKey: type) == nil {
                    let toolBtn = SecondToolBtn(height * btnWidthRatio, height * btnheightRatio, labelFont, type, mType)
                    tools[type] = toolBtn
                }
            }
        }
        
        let count: CGFloat = CGFloat(tools.count)
        width = count * height + left_right_space + (count - 1) * spacing //btn的长度+horizontal左右两边间距+btn之间的间距
        var viewFrame = self.frame
        viewFrame.size.width = width
        self.frame = viewFrame
        
        // 规范secondtools的展示顺序
        var i: Int = 0
        if let main = mainType {
            if let secondToolsOrder = getSecondToolsByOrder(main) {
                for order in secondToolsOrder {
                    if let btn = tools[order] {
                        var btnFrame = btn.frame
                        btnFrame.origin.x = CGFloat(i) * (height + spacing) + left_right_space / 2 + height * (1 - btnWidthRatio) / 2
                        btnFrame.origin.y = height * (1 - btnheightRatio) * 0.5
                        btn.frame = btnFrame
                        addSubview(btn)
                        i = i + 1
                    }
                }
            }
        }
        
//        for (_,btn) in tools {
//            var btnFrame = btn.frame
//            btnFrame.origin.x = CGFloat(i) * (height + spacing) + left_right_space / 2 + height * (1 - btnWidthRatio) / 2
//            btnFrame.origin.y = height * (1 - btnheightRatio) * 0.5
//            btn.frame = btnFrame
//            addSubview(btn)
//            i = i + 1
//        }
        
    }
    //MARK: 二级功能只需要调整view的位置
    /**
     parentBtnCenter : 对应的父btn的几何中心点
     parentBtnSize : 对应的父btn的size
     */
    func resetCenter(_ parentBtnCenter: CGPoint,parentBtnSize: CGSize) {
        self.center.x = parentBtnCenter.x
        self.center.y = parentBtnCenter.y - (parentBtnSize.height + self.bounds.height) / 2 - 10
    }
    func cancelhighlightAll() {
        for (_,btn) in tools {
            btn.highlight(false)
        }
    }
    func highlightTool(_ type: SecondToolType,Is: Bool = true) {
        tools[type]?.highlight(Is)
    }
   
}
