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
    var titleName: UILabel!
    var slider: UISlider!
    var manYouValue: UILabel!
    var leftButton: UIButton!
    var rightButton: UIButton!
    
    init(frame: CGRect) {
        super.init(frame: frame, titleName: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubview() {
        let middleCenter_y = (self.bounds.height - headerHeight) / 2 + headerHeight - 10
        
        titleName = UILabel(frame: CGRectZero)
        titleName.text = "第一人称视角"
        titleName.center.y = middleCenter_y
        titleName.font = .systemFont(ofSize: 14)
        titleName.textColor = .white
        titleName.numberOfLines = 0
        titleName.textAlignment = .center
        addSubview(titleName)
        titleName.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self.snp.left).offset(left_right_pad)
        }
        
        manYouName = UILabel(frame: CGRectZero)
        manYouName.text = "速度"
        manYouName.center.y = middleCenter_y
        manYouName.font = .systemFont(ofSize: 14)
        manYouName.textColor = .white
        manYouName.textAlignment = .left
        addSubview(manYouName)
        titleName.snp.makeConstraints { make in
            make.centerY.equalTo(titleName)
            make.left.equalTo(titleName.snp.right).offset(20)
        }
        
        slider = UISlider(frame: CGRectZero)
        slider.center.y = middleCenter_y
        slider.minimumValue = 0
        slider.maximumValue = 8
        slider.tintColor = UIColor(red: 24/255, green: 172/255, blue: 251/255, alpha: 1)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSubview(slider)
        slider.snp.makeConstraints { make in
            make.centerY.equalTo(titleName)
            make.left.equalTo(manYouName.snp.right).offset(20)
            make.width.equalTo(120)
            make.height.equalTo((self.bounds.height - headerHeight) * 0.45)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.slider.setValue(4, animated: false)
        }
        
        manYouValue = UILabel(frame: CGRectZero)
        manYouValue.center.y = middleCenter_y
        manYouValue.textAlignment = .right
        manYouValue.text = "4"
        manYouValue.textAlignment = .center
        manYouValue.textColor = .white
        manYouValue.font = .systemFont(ofSize: 13)
        addSubview(manYouValue)
        manYouValue.snp.makeConstraints { make in
            make.centerY.equalTo(slider)
            make.left.equalTo(slider.snp.right).offset(10)
            make.width.equalTo(18)
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
            make.centerY.equalTo(slider)
            make.left.equalTo(manYouValue.snp.right).offset(20)
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
            make.left.equalTo(leftButton.snp.right).offset(20)
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
        
        closeManYou(enableGravity: enableGravity, enableAllCollision: enableAllCollision, value: Int(slider.value), completion: {result in
            if !self.isHidden && !result {
                if let parentView = self.superview {
                    showTip(tip: "指令下发失败", parentView: parentView,tipColor_bg_fail,tipColor_text_fail) {}
                }
            }
        })
        
        VJMTDelegateManager.notity(needClosedMainType: .PersonView)
    }
    
    //MARK: 展示分解页面时调用
    func open() {
        self.sendManYouAction()
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
