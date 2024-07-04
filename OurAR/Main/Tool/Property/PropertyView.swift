//
//  PropertyView.swift
//  OurAR
//
//  Created by lee on 2023/6/28.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation
import UIKit
import CloudAR

class PropertyItem: UIView
{
    var key: UILabel!
    var value: UILabel!
    
    let offset_x: CGFloat = 15.0
    let fontSize: CGFloat = 12.0
    
    init(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        let halfWidth = bounds.width / 2 - offset_x
        let halfHeight = bounds.height / 2
        
        key = UILabel(frame: CGRect(x: offset_x, y: halfHeight - fontSize / 2, width: halfWidth, height: bounds.height))
        key.font = .boldSystemFont(ofSize: fontSize)
        key.textColor = .white
        key.textAlignment = .left
        key.numberOfLines = 3
        
        value = UILabel(frame: CGRect(x: halfWidth + offset_x, y: halfHeight - fontSize / 2, width: halfWidth, height: bounds.height))
        value.font = .boldSystemFont(ofSize: fontSize)
        value.textColor = .white
        value.textAlignment = .left
        value.numberOfLines = 3
        
        
        addSubview(key)
        addSubview(value)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init \(decoder) not implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateInfo(_ key: String!,_ value: String!) {
        self.key?.text = key == nil ? "1" : key
        self.value?.text = value == nil ? "1" : value
    }
}

class VJPropertyView: UIView
{
    var closeBtn: CloseButtn!
    var title: UILabel!
    var scrollView: UIScrollView!
   
    var propertyItems: [PropertyItem] = []
   
    var projectID: String = ""
    var actorID: String = ""
    
    let titleHeight: CGFloat = 30.0
    let btnSize: CGFloat = 15.0
    let title_btn_center_y: CGFloat = 30.0
    let left_right_offset: CGFloat = 15
    let fontSize: CGFloat = 18
    var scrollview_start_y: CGFloat = 0
    
    let propertyItems_up_offset: CGFloat = 10
    let propertyItemHeight: CGFloat = 30 //每一个propertyItem的高度
    var property_start_y: CGFloat = 0.0 //第一个property item开始的y
    
    //var text: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = VJViewBGColor
        
        title = UILabel(frame: CGRect(x: left_right_offset, y: 0, width: bounds.width * 0.4, height: titleHeight))
        title.text = "属性信息"
        title.textColor = .white
        title.textAlignment = .left
        title.font = .boldSystemFont(ofSize: fontSize)
        title.center.y = title_btn_center_y
        addSubview(title)
        
        closeBtn = CloseButtn(frame: CGRect(x: bounds.width - left_right_offset - btnSize, y: 0, width: btnSize, height: btnSize))
        closeBtn.center.y = title_btn_center_y
        closeBtn.addAction(UIAction(handler: { _ in
            //关闭属性面板
            VJMTDelegateManager.notity(needClosedMainType: .ShuXing)
        }), for: .touchUpInside)
        addSubview(closeBtn)
        
        property_start_y = title_btn_center_y + max(title.bounds.height, closeBtn.bounds.height) / 2 + propertyItems_up_offset
        scrollView = UIScrollView(frame: CGRect(x: 0, y: property_start_y, width: bounds.width, height: bounds.height - property_start_y))
        addSubview(scrollView)
        if getIsIphone() {
            scrollView.snp.makeConstraints { make in
                make.top.equalTo(title.snp.bottom).offset(10)
                make.left.right.bottom.equalTo(self)
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 清空所有数据
    func clear() {
        projectID = ""
        actorID = ""
        clearAllPropertyItem()
    }
    
    //清空所有property的信息
    private func clearAllPropertyItem() {
        for item in propertyItems {
            item.updateInfo("", "")
        }
    }
    //填充property的信息
    private func fillingPropertyItems(_ data: inout [[String:Any]?]) {
        var step = 0
        let count = propertyItems.count
        for result in data {
            if let re = result {
                if let key = re["name"] as? String,
                   let value = re["value"] as? String {
                    if step >= count {
                        let newItem = PropertyItem(x: 0, y: CGFloat(step) * propertyItemHeight, width: bounds.width, height: propertyItemHeight)
                        propertyItems.append(newItem)
                        scrollView?.addSubview(newItem)
                    }
                    propertyItems[step].updateInfo(key, value)
                    step += 1
                }
            }
        }
        //更新srcollview的滑动范围
        let scrollHeight = step == 0 ? bounds.height - property_start_y : CGFloat(step) * propertyItemHeight
        self.scrollView.contentSize  = CGSize(width: bounds.width, height: scrollHeight)
    }
    
    //MARK: 根据项目id和actorid 进行请求
    func updateProperty(_ newProjectID: String,_ newActorID: String) {
        //前后相等就不用更新
        if !projectID.isEmpty && actorID.isEmpty && projectID != newProjectID && actorID != newActorID {
            return
        }
        clearAllPropertyItem()
        projectID = newProjectID
        actorID = newActorID
        //为空也不用更新
        if newProjectID.isEmpty || newActorID.isEmpty {
            return
        }
        //"BIM2022031210421053" "436967"
        queryPropertyInfo(projectID: self.projectID, actorID: self.actorID) { result in
            switch result {
            case .success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON, options: .allowFragments)
                    if let json = JSONObject as? [String:Any] {
                        if let respCode = json["code"] as? Int,
                            let data = json["data"] as? [String:Any]
                        {
                            if respCode == 0
                            {
                                if let info = data["data"] as? String,
                                   let name = data["name"] as? String,
                                   let uuid = data["uuid"] as? String
                                {
                                    var results: [[String:Any]?] = car_extractInfoFromPropertyData(info)
                                    results.insert(["name":"构件名","value":name], at: 0) //构件名
                                    results.insert(["name":"构件ID","value":uuid], at: 1) //构件id
                                    self.fillingPropertyItems(&results)
                                }
                            }
                        }
                    }
                }
                
            case .failure(let Error):
                print(Error)
            }
        }
    }
    
    //MARK: 根据后端返回的点击数据 直接展示
    func updateProperty(json: inout [String:Any]) {
        clearAllPropertyItem()
        
        projectID = car_UserInfo.currProID
        actorID = json["mN"] as? String ?? ""
        
        // 判断是否是模型构件或自定义构件
        if let data = json["data"] as? [String:Any],
            let dynamicData = data["dynamicData"] as? [[String:Any]]
        {
            let name = data["name"] as? String ?? ""
            
            var results: [[String:Any]?] = dynamicData
            results.insert(["name":"构件名","value":name], at: 0) //构件名
            results.insert(["name":"构件ID","value":actorID], at: 1) //构件id
            self.fillingPropertyItems(&results)
            
        } else if var object = json["object"] as? [[String:Any]?] {
            self.fillingPropertyItems(&object)
        }
    }
}


