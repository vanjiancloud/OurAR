//
//  GJSItem.swift
//  OurAR
//
//  Created by lee on 2023/7/28.
//

import Foundation
import UIKit
import CloudAR

class GJSItem : TreeItem
{
    var proID: String = ""
    var revitCode: String = ""
    var typeId: String = "" // typeId == comp为自定义构件
    var uuid: String = ""

    init(id: String, name: String, type: FileType, collpase: Bool,hiddenModel: Bool) {
        super.init(_id: id, _name: name, _type: type, _collpase: collpase,_hiddenModel: hiddenModel)
    }
    
    override func updateAdditionalInfo(_ json: [String : Any]) {
        proID = json["projectId"] as? String ?? car_UserInfo.currProID
        revitCode = json["revitCode"] as? String ?? ""
        typeId = json["typeId"] as? String ?? ""
        uuid = json["uuid"] as? String ?? ""
    }
    
    func isCustomModel() -> Bool {
        return typeId == "comp"
    }
    
    func getNeedShowItems(outItems: inout [GJSItem]) {
        outItems.append(self)
        if !_collpase {
            for child in _children {
                if let gjsChild = child as? GJSItem {
                    gjsChild.getNeedShowItems(outItems: &outItems)
                }
            }
        }
    }
}

enum GJSCellBtnType : UInt8
{
    case collpase     = 0
    case choise       = 1
    case hidden       = 3
    case delete       = 4
}

// 单个构件栏
class VJGJSItemCell: UITableViewCell
{
    fileprivate var updownBtn: UIButton!
    fileprivate var label: UILabel!
    fileprivate var bgBtn: UIButton! // 用于点击时模拟选中效果
    fileprivate var deleteBtn: UIButton! //只有自定义构件才有
    fileprivate var hiddenBtn: UIButton!
    fileprivate var highlightImg: UIImageView!
    
    let updownBtnSize: CGFloat = 15.0
    let pad: CGFloat = 5.0
    let levelPad: CGFloat = 10.0
    var left_right_pad: CGFloat = 15.0
    
    var hiddenDeleteBtn:Bool = true
    
    var item: TreeProtocol? = nil {
        didSet {
            if let new = item {
                //  如果没有折叠（也就是没有查询子节点）并且 childrenCount == 0，则隐藏上拉下拉图标
                if (!new._collpase && new._childrenCount == 0) || new._type == .file {
                    self.updownBtn.isHidden = true
                } else {
                    self.updownBtn.isHidden = false
                    self.updownBtn.setImage(UIImage(named: new._collpase ? "pullup" : "dropdown"), for: .normal)
                }
                self.hiddenBtn.setImage(UIImage(named: new._hiddenModel ? "hidden" : "show"), for: .normal)
                self.bgBtn.setTitle(new._name, for: .normal)
                self.updateLayout()
            } else {
                
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        updownBtn = UIButton(frame: CGRect(x: 0, y: 0, width: updownBtnSize, height: updownBtnSize))
        updownBtn.center.y = self.bounds.height / 2
        updownBtn.setImage(UIImage(named: "pullup"), for: .normal)
        updownBtn.contentMode = .scaleAspectFill
        updownBtn.addAction(UIAction(handler: { _ in
            if let item = self.item {
                if item._type != .file {
                    GJSDelegateManager.notity(id: item._id, params: ["type": GJSCellBtnType.collpase,"collpase": !item._collpase])
                }
            } else {
                print("gjs item is nil")
            }
            
        }), for: .touchUpInside)
        contentView.addSubview(updownBtn)
        
        let bg_start_x: CGFloat = updownBtnSize + pad
        bgBtn = UIButton(frame: CGRect(x: bg_start_x, y: 0, width: self.bounds.width * 0.4, height: self.bounds.height))
        bgBtn.center.y = self.bounds.height / 2
        bgBtn.setTitle("", for: .normal)
        bgBtn.contentHorizontalAlignment = .left
        bgBtn.titleLabel?.textAlignment = .left
        bgBtn.titleLabel?.font  = .italicSystemFont(ofSize: 15)
        bgBtn.titleLabel?.textColor = .black
        bgBtn.addAction(UIAction(handler: {_ in
            if let item = self.item {
                GJSDelegateManager.notity(id: item._id, params: ["type": GJSCellBtnType.choise])
            } else {
                print("tag item is nil")
            }
        }), for: .touchUpInside)
        contentView.addSubview(bgBtn)
        
        // 固定的
        let hidden_center_x: CGFloat = self.bounds.width - gjsIconSize - left_right_pad
        hiddenBtn = UIButton(frame: CGRect(x: 0, y: 0, width: gjsIconSize, height: gjsIconSize))
        hiddenBtn.center = CGPoint(x: hidden_center_x, y: self.bounds.height / 2)
        hiddenBtn.contentMode = .scaleAspectFill
        hiddenBtn.addAction(UIAction(handler: {_ in
            if let item = self.item {
                GJSDelegateManager.notity(id: item._id, params: ["type": GJSCellBtnType.hidden,"hidden": !item._hiddenModel])
            } else {
                print("tag item is nil")
            }
        }), for: .touchUpInside)
        contentView.addSubview(hiddenBtn)
        
        // 固定的
        let delete_center_x: CGFloat = self.bounds.width - gjsIconSize * 2 - pad - left_right_pad
        deleteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: gjsIconSize, height: gjsIconSize))
        deleteBtn.center = CGPoint(x: delete_center_x, y: self.bounds.height / 2)
        deleteBtn.setBackgroundImage(UIImage(named: "delete"), for: .normal)
        deleteBtn.contentMode = .scaleAspectFill
        deleteBtn.addAction(UIAction(handler: {_ in
            if let item = self.item {
                //NOTICE: 只有自定义构件才有删除按钮，这里可以不需要考虑这么多
                GJSDelegateManager.notity(id: item._id, params: ["type": GJSCellBtnType.delete])
            } else {
                print("tag item is nil")
            }
        }), for: .touchUpInside)
        contentView.addSubview(deleteBtn)
        
        highlightImg = UIImageView(frame: CGRect(x: updownBtnSize + pad, y: 0, width: self.bounds.width - updownBtnSize-pad, height: self.bounds.height))
        contentView.insertSubview(highlightImg, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLayout() {
        if let treeProtocol = item {
            // 制造出一种层次感
            let level = treeProtocol._level
            
            if self.hiddenDeleteBtn {
                deleteBtn.removeFromSuperview()
            } else {
                if !self.contentView.subviews.contains(deleteBtn) {
                    self.contentView.addSubview(deleteBtn)
                }
            }
            
            let updown_center_x: CGFloat = CGFloat(level) * levelPad + updownBtnSize / 2
            
            let bgBtn_width: CGFloat = (hiddenDeleteBtn ? hiddenBtn.center.x : deleteBtn.center.x) - updown_center_x - gjsIconSize
            let bgBtn_center_x: CGFloat = updown_center_x + updownBtnSize / 2 + 5 + bgBtn_width / 2
            
            updownBtn.center.x = updown_center_x
           
            bgBtn.bounds.size.width = bgBtn_width
            bgBtn.center.x = bgBtn_center_x
            
            let highlight_start_x: CGFloat = updown_center_x + updownBtnSize/2 + pad
            let highlight_width: CGFloat = self.bounds.width - highlight_start_x
            highlightImg.bounds.size.width = highlight_width
            highlightImg.frame.origin.x = highlight_start_x
            
        } else {
            self.isHidden = true
        }
    }
    
    func highlight(_ highlight: Bool) {
        self.highlightImg.backgroundColor = highlight ? UIColor(white: 0.6, alpha: 1) : nil
    }
}
