//
//  ManYou.swift
//  OurAR
//
//  Created by lewen on 2025/8/22.
//

import Foundation
import UIKit

class ManYou: GTView {
    var manYouName: UILabel!
    var slider: UISlider!
    var manYouValue: UILabel!
    var leftButton: UIButton!
    var rightButton: UIButton!
    
    init(frame: CGRect) {
        super.init(frame: frame, titleName: "漫游导航")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubview() {
        let middleCenter_y = (self.bounds.height - headerHeight) / 2 + headerHeight -  40
        
        let manYouNameWidth: CGFloat = self.bounds.width * 0.2
        manYouName = UILabel(frame: CGRect(x: left_right_pad, y: 0, width: manYouNameWidth, height: 18))
        manYouName.text = "速度"
        manYouName.center.y = middleCenter_y
        manYouName.font = .systemFont(ofSize: 14)
        manYouName.textColor = .white
        manYouName.textAlignment = .left
        addSubview(manYouName)
        
        let manYouValueWidth: CGFloat = 25
        manYouValue = UILabel(frame: CGRect(x: self.bounds.width - left_right_pad-manYouValueWidth, y: 0, width: manYouValueWidth, height: 18))
        manYouValue.center.y = middleCenter_y
        manYouValue.textAlignment = .right
        manYouValue.text = "4"
        manYouValue.textColor = .white
        manYouValue.font = .systemFont(ofSize: 13)
        addSubview(manYouValue)
        
        let sliderWidth = self.bounds.width - left_right_pad * 2 - manYouNameWidth - manYouValueWidth - 5 * 2
        let sliderHeight = (self.bounds.height - headerHeight) * 0.45
        slider = UISlider(frame: CGRect(x: left_right_pad + manYouNameWidth + 5, y: 0, width: sliderWidth, height: sliderHeight))
        slider.center.y = middleCenter_y
        slider.minimumValue = 0
        slider.maximumValue = 8
        slider.tintColor = UIColor(red: 24/255, green: 172/255, blue: 251/255, alpha: 1)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSubview(slider)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.slider.setValue(4, animated: false)
        }
        
        leftButton = UIButton(frame:CGRectZero)
        leftButton.contentMode = .scaleAspectFit
        let targetImageSize = CGSize(width: 16, height: 16)
        if let normalImage = UIImage(named: "remenberuncheck"),
           let selectedImage = UIImage(named: "remenbercheck") {
                let resizedNormalImage = resizeImage(image: normalImage, targetSize: targetImageSize)
                let resizedSelectedImage = resizeImage(image: selectedImage, targetSize: targetImageSize)
            
            leftButton.setImage(resizedSelectedImage, for: .selected)
            leftButton.setImage(resizedNormalImage, for: .normal)
        }
        leftButton.isSelected = true
        leftButton.setTitle(" 重力", for: .selected)
        leftButton.setTitle(" 重力", for: .normal)
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.setTitleColor(.white, for: .selected)
        leftButton.titleLabel?.font = .systemFont(ofSize: 14)
        leftButton.addAction(UIAction(handler: {_ in
            self.leftClick()
        }),for: .touchUpInside)
        addSubview(leftButton)
        leftButton.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(12)
            make.left.equalTo(slider.snp.left)
            make.size.equalTo(CGSizeMake(55, 20))
        }
        
        rightButton = UIButton(frame:CGRectZero)
        rightButton.contentMode = .scaleAspectFit
        if let normalImage = UIImage(named: "remenberuncheck"),
           let selectedImage = UIImage(named: "remenbercheck") {
                let resizedNormalImage = resizeImage(image: normalImage, targetSize: targetImageSize)
                let resizedSelectedImage = resizeImage(image: selectedImage, targetSize: targetImageSize)
            
                rightButton.setImage(resizedSelectedImage, for: .selected)
                rightButton.setImage(resizedNormalImage, for: .normal)
        }
        rightButton.isSelected = true
        rightButton.setTitle(" 碰撞", for: .selected)
        rightButton.setTitle(" 碰撞", for: .normal)
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.setTitleColor(.white, for: .selected)
        rightButton.titleLabel?.font = .systemFont(ofSize: 14)
        rightButton.addAction(UIAction(handler: {_ in
            self.rightClick()
        }),for: .touchUpInside)
        addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(leftButton)
            make.left.equalTo(leftButton.snp.right).offset(12)
            make.size.equalTo(CGSizeMake(55, 20))
        }
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = true
        addGestureRecognizer(tapGesture)
    }
    
    private func leftClick() {
        leftButton.isSelected = !leftButton.isSelected
        self.sendManYouAction()
    }
    
    private func rightClick() {
        rightButton.isSelected = !rightButton.isSelected
        self.sendManYouAction()
    }
    
    @objc private func handleBackgroundTap() {
        
    }
    
    override func handleClose() {
        VJMTDelegateManager.notity(needClosedMainType: .PersonView)
    }
    
    //MARK: 展示分解页面时调用
    func open() {

    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let scale = min(widthRatio, heightRatio)
        
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider?,for event: UIEvent?) {
        guard let slider = slider else { return }
           
        // 实时取整（关键修改）
        let roundedValue = round(slider.value)
        if slider.value != roundedValue {
            slider.value = roundedValue
        }
        
        if let touchEvent = event?.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                break
            case .cancelled:
                break
            case .moved:
                manYouValue.text = String(Int(slider.value))
                break
            case .ended:
                print("slider end")
                self.sendManYouAction()
            default:
                break
            }
        }
    }
    
    private func sendManYouAction() {
        var enableGravity: String
        var enableAllCollision: String
        
        if leftButton.isSelected {
            enableGravity = "true"
        } else {
            enableGravity = "false"
        }
        
        if rightButton.isSelected {
            enableAllCollision = "true"
        } else {
            enableAllCollision = "false"
        }
        
        sendManYou(enableGravity: enableGravity, enableAllCollision: enableAllCollision, value: Int(slider.value), completion: {result in
            if !self.isHidden && !result {
                if let parentView = self.superview {
                    showTip(tip: "指令下发失败", parentView: parentView,tipColor_bg_fail,tipColor_text_fail) {}
                }
            }
        })
    }
}
