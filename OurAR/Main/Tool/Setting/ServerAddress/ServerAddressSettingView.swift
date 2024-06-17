//
//  ServerAddressSettingView.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation
import UIKit

class ServerAddressSettingCell: UITableViewCell
{
    var check: UIImageView!
    var name: UILabel!
    var focus: UIButton!
    var modify: UIButton!
    var delete: UIButton!
    var settingProtocol: SettingProtocol!
    //0是id，1是name
    var settingInfo: (SettingType,String,String)? = nil {
        didSet {
            if let new = settingInfo {
                name.text = new.2
            } else {
                name.text = ""
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        let width: CGFloat = self.bounds.width
        let height: CGFloat = self.bounds.height
        let center_y: CGFloat = height / 2
        check = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        check.center.y = center_y
        check.image = UIImage(named: "settingunchoice")
        check.contentMode = .scaleToFill
        contentView.addSubview(check)
        name = UILabel(frame: CGRect(x: check.bounds.width + 10 + 10, y: 0, width:width*0.5, height: height))
        name.center.y = center_y
        name.font = .systemFont(ofSize: 14)
        contentView.addSubview(name)
        focus = UIButton(frame: CGRect(x: 0, y: 0, width: width-20-10-20-5, height: height * 0.8))
        focus.center.y = center_y
        focus.addAction(UIAction(handler: {_ in
            //选中
            if let info = self.settingInfo {
                self.settingProtocol?.handleSetting(type: info.0,action: .choice, info: ["id":info.1])
            }

        }), for: .touchUpInside)
        contentView.addSubview(focus)

        delete = UIButton(frame: CGRect(x: width - 20, y: 0, width: 25, height: 25))
        delete.center.y = center_y
        delete.setBackgroundImage(UIImage(named: "delete"), for: .normal)
        delete.contentMode = .scaleToFill
        delete.addAction(UIAction(handler: {_ in
            //弹出删除页面
            //print("弹出删除页面")
            if let info = self.settingInfo {
                print("弹出删除页面")
                self.settingProtocol?.handleSetting(type: info.0,action: .delete, info: ["id":info.1])
            }
        }), for: .touchUpInside)
        contentView.addSubview(delete)
        modify = UIButton(frame: CGRect(x: width-20-10-20, y: 0, width: 25, height: 25))
        modify.center.y = center_y
        modify.setBackgroundImage(UIImage(named: "modify"), for: .normal)
        modify.contentMode = .scaleToFill
        modify.addAction(UIAction(handler: {_ in
            //弹出修改页面
            if let info = self.settingInfo {
                self.settingProtocol?.handleSetting(type: info.0,action: .modify, info: ["id":info.1])
            }
        }), for: .touchUpInside)
        contentView.addSubview(modify)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func choice(_ ischoice: Bool) {
        self.check.image = UIImage(named: ischoice ? "settingchoice" : "settingunchoice")
    }
}

class ServerAddressSettingView: UIView
{
    var addBtn: UIButton!
    var table: UITableView!
    var settingProtocol: SettingProtocol!
    
    init(frame: CGRect,type: SettingType) {
        super.init(frame: frame)
        let width: CGFloat = frame.width
        let height: CGFloat = frame.height
        
        table = UITableView(frame: CGRect(x: 0, y: 0, width: width, height: height - 30))
        table.register(ServerAddressSettingCell.self, forCellReuseIdentifier: "serverAddressSettingCell")
        table.separatorStyle = .none
        table.backgroundColor = .none
        addSubview(table)
        
        addBtn = UIButton(frame: CGRect(x: width-40, y: height-40, width: 30, height: 30))
        addBtn.setBackgroundImage(UIImage(named: "settingadd"), for: .normal)
        addBtn.contentMode = .scaleToFill
        addBtn.addAction(UIAction(handler: {_ in
            self.settingProtocol?.handleSetting(type: type,action: .add, info: [:])
        }), for: .touchUpInside)
        addSubview(addBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
