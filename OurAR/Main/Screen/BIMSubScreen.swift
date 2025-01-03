//
//  BIMScreen.swift
//  OurAR
//
//  Created by lee on 2023/6/2.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import UIKit
import Foundation
import CloudAR

class BIMSubScreenView : BaseView
{
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
    
    var scaleAdjustView: ScaleAdjustView! //尺寸调整
    var needShowScaleAdjust: Bool = false
    
    override func initSubView() {
        exitScreenBtn = BackBtnView(x: 0, y: 20, width: 40, height: 40)
        exitScreenBtn.btn?.addAction(UIAction(handler: {_ in
           print("click back btn")
            MLDelegateManager.notity()
        }), for: .touchUpInside)
        addSubview(exitScreenBtn)
        
        vjSwitchModeView = SwitchModeView(x: 0, y: 100)
        addSubview(vjSwitchModeView)
        
        sliderView = SliderView(x: 0, y: 300,width: 170,height: 38)
        sliderView.minimumValue = 0
        sliderView.maximumValue = 1
        sliderView.value = 1
        sliderView.center.x = vjSwitchModeView.center.x
        sliderView.isContinuous = false
        sliderView.setMinimumTrackImage(UIImage(named: "img_light_off_on"), for: .normal)
        sliderView.setMaximumTrackImage(UIImage(named: "img_light_off_back"), for: .normal)
        sliderView.setThumbImage(UIImage(named: "img_light_round"), for: .normal)
        sliderView.setThumbImage(UIImage(named: "img_light_round"), for: .highlighted)
        sliderView.transform = CGAffineTransformRotate(sliderView.transform, -M_PI/2)
        sliderView .addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        sliderView.isHidden =  true
        addSubview(sliderView)
        
        scaleAdjustView = ScaleAdjustView(frame: CGRect(x: 0, y: bounds.height - 80, width: 250, height: 60))
        addSubview(scaleAdjustView)
        scaleAdjustView.isHidden = true
        
        enterPositionView = EnterPositionView(x: 65, y: 20,width: 40,height: 40)
        addSubview(enterPositionView)
        enterPositionView.isHidden =  true
        
        vjMainToolView = MainToolView(x: 0, y: frame.height - 90)
        vjMainToolView.contentMode = .center
        vjMainToolView.center.x = frame.width / 2
        addSubview(vjMainToolView)
        
        //初始化二级功能按钮view
        for (mainType,info) in car_EngineStatus.mainToolsInfo.info {
            if let _ = info.secondTools
            {
                let secondToolView = SecondToolView(mainType: mainType)
                vjSecondToolViews[mainType] = secondToolView
                addSubview(secondToolView)
                secondToolView.isHidden = true
            }
        }
        
        //let sliderviewFrame: CGRect = CGRect(x: bounds.width - 330, y: 0, width: 330, height: bounds.height * 0.8)
        let sliderviewFrame: CGRect = CGRect(x: 0, y: 0, width: 330, height: bounds.height)
        //初始化属性面板
        vjPropertyView = VJPropertyView(frame: sliderviewFrame)
        addSubview(vjPropertyView)
        vjPropertyView.isHidden = true
        
        //初始化标签面板
        vjTagView = TagView(frame: sliderviewFrame)
        addSubview(vjTagView)
        vjTagView.isHidden = true
        
        //初始化构件树面板
        vjGJSView = GoujianshuView(frame: sliderviewFrame)
        addSubview(vjGJSView)
        vjGJSView.isHidden = true
        
        //初始化分解面板
        vjFenJieView = FenJieView(frame: CGRect(x: 0, y: 0, width: 330, height: 100))
        vjFenJieView.center = CGPoint(x: self.bounds.width - 330/2, y: self.bounds.height - 100/2)
        vjFenJieView.layer.mask = makeMask(8,self.bounds,[.topLeft])
        addSubview(vjFenJieView)
        vjFenJieView.isHidden = true
        if getIsIphone() {
            exitScreenBtn.snp.makeConstraints { make in
                make.top.equalTo(self).offset(20)
                make.left.equalTo(self)
                make.height.equalTo(40)
                make.width.equalTo(50)
            }
            vjSwitchModeView.snp.makeConstraints { make in
                make.top.equalTo(exitScreenBtn.snp.bottom).offset(30)
                make.left.equalTo(30)
                make.width.equalTo(50)
                make.height.equalTo(90)
            }
            scaleAdjustView.snp.makeConstraints { make in
                make.bottom.equalTo(self).offset(-80)
                make.left.equalTo(0)
                make.width.equalTo(250)
                make.height.equalTo(60)
            }
            enterPositionView.snp.makeConstraints { make in
                make.top.equalTo(exitScreenBtn)
                make.left.equalTo(exitScreenBtn.snp.right).offset(20)
                make.width.height.equalTo(40)
            }
            vjMainToolView.snp.makeConstraints { make in
                make.bottom.equalTo(self).offset(-15)
                make.width.equalTo(100)
                make.centerX.equalTo(self)
                make.height.equalTo(65)
            }
            vjPropertyView.snp.makeConstraints { make in
                make.left.equalTo(self).offset(30)
                make.top.bottom.equalTo(self)
                make.width.equalTo(330)
            }
            vjTagView.snp.makeConstraints { make in
                make.left.equalTo(self).offset(30)
                make.top.bottom.equalTo(self)
                make.width.equalTo(330)
            }
            vjGJSView.snp.makeConstraints { make in
                make.left.equalTo(self).offset(30)
                make.top.bottom.equalTo(self)
                make.width.equalTo(330)
            }
            vjFenJieView.snp.makeConstraints { make in
                make.right.equalTo(self).offset(-20)
                make.bottom.equalTo(self).offset(-15)
                make.width.equalTo(330)
                make.height.equalTo(100)
            }
        }
    }
    
    @objc func sliderValueChange(slider:UISlider) {
        setSliderValue(value: slider.value)
    }
    
    func setSliderValue(value:Float) {
        car_EngineStatus.modelAlpha = value
    }
    
    private func showToolPage(_ type: MainToolType?) {
        //0.0 所有的main second tool重置
        hiddenAllSecondTool() //隐藏所有的二级功能栏
        hiddenAllSecondView() //隐藏所有二级功能其他的view
        vjMainToolView?.cancelHighLightAll()
        if type == nil {
            return
        }
        //0.1 MainTool
        vjMainToolView?.highlightTool(type!)
        
        //1.1 二级功能按钮
        //该二级功能按钮所属的mainBtn是否存在
        if let mainBtn = vjMainToolView.tools[type!] {
            hiddenSecondTool(type!,false) //展示所要开启的
            vjSecondToolViews[type!]?.cancelhighlightAll() //重置二级功能栏状态
            let viewOri = vjMainToolView.frame.origin
            let btnCenter = mainBtn.center
            let btnCenter_Absolut = CGPoint(x: viewOri.x + btnCenter.x, y: viewOri.y + btnCenter.y)
            vjSecondToolViews[type!]?.resetCenter(btnCenter_Absolut, parentBtnSize: mainBtn.frame.size) //重置功能栏的位置
        }
        //1.2 其他页面
        showAndInitSecondView(type!)
        
    }
    private func showAndInitSecondView(_ type: MainToolType) {
        //展示view
        hiddenSecondView(type, false)
        //对view进行一些初始处理
        switch type {
        case .MainView: break
        case .PersonView: break
        case .GouJianShu:
            vjGJSView?.open()
        case .ShuXing:
            if let vjbimScreenSubCon = self.next as? BIMScreenSubController {
                updatePropertyView(car_UserInfo.currProID , vjbimScreenSubCon.clickedActorID.first?.actorId ?? "")
            }
        case .Celiang:
            break
        case .BiaoQian:
            vjTagView?.open()
        case .KeJianXing: break
        case .FenJie:
            vjFenJieView?.open()
            break
        case .PouQie:
            //TODO: 待完成剖切页面
            break
        }
    }
    
    private func hiddenAllSecondView() {
        vjPropertyView?.isHidden = true
        vjTagView?.isHidden = true
        vjGJSView?.isHidden = true
        vjFenJieView?.isHidden = true
    }
    private func hiddenAllSecondTool() {
        for (_,btn) in vjSecondToolViews {
            btn.isHidden = true
        }
    }
    private func hiddenSecondView(_ type: MainToolType,_ Is: Bool = true) {
        switch type {
        case .MainView: break
        case .PersonView: break
        case .GouJianShu:
            vjGJSView?.isHidden = Is
        case .ShuXing:
            vjPropertyView?.isHidden = Is
        case .Celiang: break
        case .BiaoQian:
            vjTagView?.isHidden = Is
        case .KeJianXing: break
        case .FenJie:
            vjFenJieView?.isHidden = Is
            break
        case .PouQie:
            //TODO: 待完成
            break
        }
    }
    private func hiddenSecondTool(_ type: MainToolType,_ Is: Bool = true) {
        vjSecondToolViews[type]?.isHidden = Is
    }
    
    private func hiddenWhenClickMainTool(_ type: MainToolType?) {
        guard let mainType = type else {
            vjMainToolView?.isHidden = false
            hiddenLeftView(false)
            hiddenRightView(false)
            return
        }
        var hiddenLeft = false //是否需要隐藏左边的
        let hiddenRight = false //是否需要隐藏右边的
        var hiddenMainTool = false //是否需要隐藏底部的miantool
        switch mainType {
        case .MainView:
            break
        case .KeJianXing:
            break
        case .PouQie:
            break
        case .FenJie:
            hiddenMainTool = true
            break
        case .PersonView:
            //TODO: 需要变动
            break
        case .Celiang:
            break
        case .GouJianShu:
            hiddenLeft = true
            break
        case .ShuXing:
            hiddenLeft = true
            break
        case .BiaoQian:
            hiddenLeft = true
            break
        }
        vjMainToolView?.isHidden = hiddenMainTool
        hiddenLeftView(hiddenLeft)
        hiddenRightView(hiddenRight)
    }
    //MARK: 展示隐藏左边的页面，非maintool secondtool及相关的页面
    private func hiddenLeftView(_ hidden: Bool) {
        exitScreenBtn?.isHidden = hidden
        vjSwitchModeView?.isHidden = hidden
        if car_EngineStatus.screenMode == .AR {
            enterPositionView?.isHidden = hidden
            sliderView?.isHidden =  hidden
            
            if needShowScaleAdjust {
                scaleAdjustView?.isHidden = hidden
            }
        }
    }
    //MARK: 展示隐藏右边的页面，非miantool secondtool及相关的页面
    private func hiddenRightView(_ hidden: Bool) {
        //NOTICE: 待补充
    }
    
    //MARK: 主要处理页面展示相关的逻辑
    func handleMainToolClick(_ newType: MainToolType,_ oldType: MainToolType?) {
        //像这种直接触发的不需要展示页面
        if newType == .MainView {
            return
        }
        let mainToolType: MainToolType? //最终的tool
        if let lastType = oldType {
            //处理当前type的相关页面展示: 如果两次相同则关闭
            if lastType == newType {
                mainToolType = nil
            } else {
                mainToolType = newType
            }
        } else {
            mainToolType = newType
        }
        // 展示工具栏相应的页面
        showToolPage(mainToolType)
        // 这里判断是否需要并隐藏maintool栏
        hiddenWhenClickMainTool(mainToolType)
    }
    //MARK: 根据secondbtn的点击，来展示相应的页面
    func showCurrSecondTools(_ mainType: MainToolType,_ secondTypes: [SecondToolType]) {
        if let secondView = vjSecondToolViews[mainType] {
            secondView.cancelhighlightAll()
            for type in secondTypes {
                secondView.highlightTool(type)
            }
        }
    }
    //MARK: 根据projectID和actorID
    func updatePropertyView(_ projectID: String,_ actorID: String) {
        if !vjPropertyView!.isHidden {
            vjPropertyView!.updateProperty(projectID, actorID)
        }
    }
    //MARK: 跟据后端推过来的数据显示
    func updatePropertyView(_ json: inout [String:Any]) {
        if !vjPropertyView!.isHidden {
            vjPropertyView?.updateProperty(json: &json)
        }
    }
    //MARK: 监听模式的切换
    func listenSwitchScreenMode(toScreenMode: car_ScreenMode) {
        //一级菜单的重置
        vjMainToolView!.isHidden = false
        var width = vjMainToolView!.resetFrame()
        if getIsIphone() {
            vjMainToolView.snp.updateConstraints { make in
                make.width.equalTo(width)
            }
        }
        vjMainToolView!.cancelHighLightAll()
        //二级菜单的重置
        hiddenAllSecondTool() //隐藏所有的二级功能栏
        hiddenAllSecondView() //隐藏所有二级功能其他的view
        vjSecondToolViews.forEach{ (_,secondView) in
            secondView.cancelhighlightAll() //取消二级菜单的高亮
        }
        switch toScreenMode {
            case .AR:
                enterPositionView?.isHidden = false
                sliderView.isHidden =  false
                needShowScaleAdjust = false
                scaleAdjustView.isHidden = true
                break
            case .ThreeD:
                enterPositionView?.isHidden = true
                sliderView.isHidden =  true
                scaleAdjustView.isHidden = true
                break
            case .None:
                break
            default:
                break
        }
        //其他页面的数据重置
        vjPropertyView.clear()
        vjGJSView.clear()
        vjTagView.clear()
    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        // 检查点击是否发生在当前视图的边界之外
//        for subview in subviews {
//            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
//                // 点击发生在子视图上，不处理点击
//                return false
//            }
//        }
//        // 点击没有发生在子视图上，处理点击
//        return true
//    }
    
    /*
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 如果想要这个view接收事件，则直接返回self
        // 如果不想接收，则调用super.hitTest(_:with:)来进行判断
        // 可以在此基础上添加自定义逻辑
//        if shouldReceiveTouchAtPoint(point) {
//            return self
//        }
//        return super.hitTest(point, with: event)
        
        for subview in subviews {
            if CGRectContainsPoint(subview.frame, point) {
                if subview.isKindOfClass(VJPropertyView) {
                    print("VJPropertyView")
                    return subview
                    
                }
            }
        }
         
//        if self.isUserInteractionEnabled, self.alpha > 0.01, let subview = super.hitTest(point, with: event) {
//            return subview
//        }
        return nil
    }
    
    private func shouldReceiveTouchAtPoint(_ point: CGPoint) -> Bool {
        // 自定义逻辑，判断点是否在视图的某个区域内
        return self.bounds.contains(point)
    }
     */
}
