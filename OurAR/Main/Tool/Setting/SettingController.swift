//
//  Setting.swift
//  OurAR
//
//  Created by lee on 2023/8/1.
//

import Foundation
import UIKit
import CloudAR

class SettingController: UIViewController
{
    var contentView: UIView!
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let contentWidth: CGFloat = 350
    let contentHeight: CGFloat = UIScreen.main.bounds.height
    
    let subFrame = CGRect(x: 0, y: 0, width: 350, height: UIScreen.main.bounds.height - 50 - 40)
    
    private lazy var serverController = ServerSettingController(frame: subFrame)
    private lazy var addressController = AddressSettingController(frame: subFrame)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0) // 整个大背景设为透明
        
        
        contentView = UIView(frame: CGRect(x: width - contentWidth, y: 0, width: contentWidth, height: height))
        contentView.backgroundColor = VJTextColor_07
            //.hex(0xFAFBFC)
        
        let segments = ["服务配置","地址配置"]
        let segmented = UISegmentedControl(items: segments)
        
        segmented.selectedSegmentIndex = 0
        segmented.frame = CGRect(x: 0, y: contentHeight - 80, width: contentWidth * 0.66, height: 40)
        segmented.center.x = contentWidth / 2
        segmented.addTarget(self, action: #selector(self.segmentChang(_:)), for: .valueChanged)
        segmented.backgroundColor = .none
        contentView.addSubview(segmented)
        
        addChild(serverController)
        serverController.didMove(toParent: self)
        
        addChild(addressController)
        addressController.didMove(toParent: self)
        
        contentView.addSubview(serverController.view)
        
        registerGesture()
        
        
        self.view.addSubview(contentView)
    }
    
    private func registerGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !contentView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    @objc func segmentChang(_ sender: AnyObject?) {
        if let segment = sender as? UISegmentedControl {
            serverController.view.removeFromSuperview()
            addressController.view.removeFromSuperview()
            
            switch segment.selectedSegmentIndex {
            case 0:
                contentView.addSubview(serverController.view)
                break
            case 1:
                contentView.addSubview(addressController.view)
                break
            default:
                break
            }
        }
    }
    
    func initConfig() {
        // 修改服务器地址
        // 120.86.64.201 东莞
        // 192.168.200.233 本地
        // 111.162.225.138 天津
        // 192.168.3.244 gt
        
        //car_UserInfo.hostID =   "10.116.201.1";
        //car_UserInfo.cloudarIP =   "183.36.29.37";
        
        serverController.initConfig()
        addressController.initConfig()
    }
}
