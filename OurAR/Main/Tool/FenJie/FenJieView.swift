//
//  FenJieView.swift
//  OurAR
//
//  Created by lee on 2023/8/3.
//

import Foundation
import UIKit

class GTView: UIView
{
    var closeBtn: UIButton!
    var title: UILabel!
    
    let headerHeight: CGFloat = 50
    let left_right_pad:CGFloat = 15.0
    let closeBtnSize: CGFloat = 15.0
    let titleHeight: CGFloat = 30.0
    
    init(frame: CGRect,titleName:String) {
        super.init(frame: frame)
        
        self.backgroundColor = VJViewBGColor
        
        closeBtn = UIButton(frame: CGRect(x: left_right_pad, y: 0, width: closeBtnSize, height: closeBtnSize))
        closeBtn.setBackgroundImage(UIImage(named: "close"), for: .normal)
        closeBtn.center.y = headerHeight / 2
        closeBtn.contentMode = .scaleAspectFill
        closeBtn.addAction(UIAction(handler: {_ in
            self.handleClose()
        }), for: .touchUpInside)
        addSubview(closeBtn)
        
        title = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width * 0.5, height: titleHeight))
        title.center.y = headerHeight / 2
        title.center.x = self.bounds.width / 2
        title.textAlignment = .center
        title.text = titleName
        title.textColor = .white
        addSubview(title)
        
        initSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubview() {}
    func handleClose() {}
}

class FenJieView: GTView
{
    var fenjieName: UILabel!
    var slider: UISlider!
    var fenjieValue: UILabel!
    
    init(frame: CGRect) {
        super.init(frame: frame, titleName: "分解")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubview() {
        let middleCenter_y = (self.bounds.height - headerHeight) / 2 + headerHeight
        
        let fenjieNameWidth: CGFloat = self.bounds.width * 0.2
        fenjieName = UILabel(frame: CGRect(x: left_right_pad, y: 0, width: fenjieNameWidth, height: 18))
        fenjieName.text = "分解幅度"
        fenjieName.center.y = middleCenter_y
        fenjieName.font = .systemFont(ofSize: 14)
        fenjieName.textColor = .white
        fenjieName.textAlignment = .left
        addSubview(fenjieName)
        
        let fenjieValueWidth: CGFloat = 25
        fenjieValue = UILabel(frame: CGRect(x: self.bounds.width - left_right_pad-fenjieValueWidth, y: 0, width: fenjieValueWidth, height: 18))
        fenjieValue.center.y = middleCenter_y
        fenjieValue.textAlignment = .right
        fenjieValue.text = "0"
        fenjieValue.textColor = .white
        fenjieValue.font = .systemFont(ofSize: 13)
        addSubview(fenjieValue)
        
        let sliderWidth = self.bounds.width - left_right_pad * 2 - fenjieNameWidth - fenjieValueWidth - 5 * 2
        let sliderHeight = (self.bounds.height - headerHeight) * 0.45
        slider = UISlider(frame: CGRect(x: left_right_pad + fenjieNameWidth + 5, y: 0, width: sliderWidth, height: sliderHeight))
        slider.center.y = middleCenter_y
        slider.setValue(0, animated: false)
        slider.minimumValue = 0
        slider.maximumValue = 10
        //slider.setThumbImage(UIImage(named: "sliderdot"), for: .normal)
        slider.tintColor = UIColor(red: 24/255, green: 172/255, blue: 251/255, alpha: 1)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSubview(slider)
    }
    
    override func handleClose() {
        VJMTDelegateManager.notity(needClosedMainType: .FenJie)
    }
    
    //MARK: 展示分解页面时调用
    func open() {
        slider?.setValue(0, animated: false)
        fenjieValue?.text = "0"
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider?,for event: UIEvent?) {
        if let touchEvent = event?.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                break
            case .cancelled:
                break
            case .moved:
                fenjieValue.text = String(Int(slider?.value ?? 0))
                break
            case .ended:
                print("slider end")
                sendFenJie(value: Int(slider!.value), completion: {result in
                    if !self.isHidden && !result {
                        if let parentView = self.superview {
                            showTip(tip: "指令下发失败", parentView: parentView,tipColor_bg_fail,tipColor_text_fail) {}
                        }
                    }
                })
            default:
                break
            }
        }
    }
}
