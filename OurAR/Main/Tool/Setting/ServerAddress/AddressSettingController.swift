//
//  AddressSettingController.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation
import UIKit
import CloudAR

class AddressSettingController: UIViewController, UITableViewDataSource, UITableViewDelegate,SettingProtocol,SettingAlertProtocol
{
    var config: [AddressInfo] = []
    var current: String!
    private let fileName = "address"
    
    var settingView: ServerAddressSettingView!
    
    var deleteAlert: UIAlertController? //删除的Alert
    var modifyAlert: UIAlertController? //修改的Alert
    var addAlert: UIAlertController? //新增的Alert
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        settingView = ServerAddressSettingView(frame: frame, type: .address)
        self.view = settingView
        settingView.settingProtocol = self
        settingView.table.dataSource = self
        settingView.table.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initConfig() {
        var hasConfig = 0
        self.config.removeAll()
        //读ip配置
        if existOfFile(fileName: fileName, extension: .txt) {
            if let content = readFile(name: fileName, extension: .txt) {
                if let data = content.data(using: .utf8) {
                    if let json = car_dataToJson(from: data),
                       let currentID = json["current"] as? String,
                       let list = json["list"] as? [[String:Any]]
                    {
                        self.current = currentID
                        list.forEach{(item) in
                            if let hostID = item["hostID"] as? String,
                               let cloudarIP = item["cloudarIP"] as? String,
                               let name = item["name"] as? String,
                               let id = item["id"] as? String
                            {
                                let address = AddressInfo()
                                address.id = id
                                address.name = name
                                address.hostID = hostID
                                address.cloudarIP = cloudarIP
                                config.append(address)
                                hasConfig = hasConfig | (id == self.current ? 1 : 0)
                            }
                        }
                    }
                }
            }
        }
        //没有的话就写一份默认的
        if hasConfig == 0 {
            let baseConfig = AddressInfo()
            baseConfig.name = "默认地址配置"
            baseConfig.hostID = car_UserInfo.hostID
            baseConfig.cloudarIP = car_UserInfo.cloudarIP
            self.current = baseConfig.id
            self.config.append(baseConfig)
            writeConfig()
            print("配置中未有address info")
        } else {
            if let item = config.first(where: {$0.id == self.current}) {
                car_UserInfo.cloudarIP = item.cloudarIP
                car_UserInfo.hostID = item.hostID
                print("从配置中初始化address info,cloudIP:\(car_UserInfo.cloudarIP),hostID: \(car_UserInfo.hostID)")
            }
        }
    }
    
    private func writeConfig() {
        print("write address config")
        //写入默认的值
        var info: [String:Any] = [:]
        var list: [[String:Any]] = []
        info["current"] = self.current
        config.forEach{(item) in
            let one: [String:Any] = ["id":item.id!,"name":item.name!,"hostID":item.hostID!,"cloudarIP":item.cloudarIP!]
            list.append(one)
        }
        info["list"] = list
        
        if let content = car_jsonString(from: &info) {
            writeFile(name: fileName, extension: .txt, info: content)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.config.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "serverAddressSettingCell", for: indexPath) as? ServerAddressSettingCell {
            cell.selectionStyle = .none
            cell.settingInfo = (SettingType.address,config[indexPath.row].id,config[indexPath.row].name)
            cell.settingProtocol = self
            cell.choice(self.current == config[indexPath.row].id)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }
    //MARK: SettingAlertProcotol
    func handleAlertAction(alertType: SettingAlertType,actionType: SettingAlertActionType, id: String, info: [String : Any]) {
        switch alertType {
        case .add:
            switch actionType {
            case .cancel:
                break
            case .confirm:
                if let name = info["name"] as? String,
                   let hostID = info["hostID"] as? String,
                   let cloudarIP = info["cloudarIP"] as? String
                {
                    let new = AddressInfo()
                    new.name = name
                    new.hostID = hostID
                    new.cloudarIP = cloudarIP
                    self.config.append(new)
                    
                    self.settingView.table?.beginUpdates()
                    self.settingView.table?.insertRows(at: [IndexPath(row: self.config.count - 1, section: 0)], with: .right)
                    self.settingView.table?.endUpdates()
                    
                    writeConfig()
                }
            }
            break
        case .delete:
            switch actionType {
            case .cancel:
                break
            case .confirm:
                self.config.removeAll(where: {$0.id == id})
                
                //如果删除的是当前选中的，则选取下一个作为选中
                if self.current == id  && self.config.count > 0{
                    if let item = self.config.first {
                        self.current = item.id
                        car_UserInfo.cloudarIP = item.cloudarIP
                        car_UserInfo.hostID = item.hostID
                    }
                }
                
                self.settingView.table.reloadData()
                writeConfig()
                break
            }
            break
        case .modify:
            switch actionType {
            case .cancel: break
            case .confirm:
                if let name = info["name"] as? String,
                   let hostID = info["hostID"] as? String,
                   let cloudarIP = info["cloudarIP"] as? String
                {
                    if let row = self.config.firstIndex(where: {$0.id == id}) {
                        self.config.first(where: {$0.id == id})?.update(name: name, hostID: hostID, cloudarIP: cloudarIP)
                        self.settingView.table?.beginUpdates()
                        self.settingView.table?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                        self.settingView.table?.endUpdates()
                        
                        //如果修改的是当前正在使用的，则需要更新userinfo
                        if self.current == id {
                            car_UserInfo.cloudarIP = cloudarIP
                            car_UserInfo.hostID = hostID
                        }
                        
                        writeConfig()
                    }
                }
            }
            break
        }
    }
    //MARK: Settingprocotol
    func handleSetting(type: SettingType, action: SettingActionType, info: [String : Any]) {
        if type == .address {
            switch action {
            case .add:
                showAddAlert()
                break
            case .choice:
                if let id = info["id"] as? String {
                    if self.current != id {
                        let oldCurr = self.current
                        let result = configAnother(newID: id)
                        
                        if result {
                            if let oldRow = self.config.firstIndex(where: {$0.id == oldCurr}),
                            let newRow = self.config.firstIndex(where: {$0.id == id})
                            {
                                let oldCell = self.settingView.table.cellForRow(at: IndexPath(row: oldRow, section: 0)) as? ServerAddressSettingCell
                                let newCell = self.settingView.table.cellForRow(at: IndexPath(row: newRow, section: 0)) as? ServerAddressSettingCell
                                oldCell?.choice(false)
                                newCell?.choice(true)
                            }
                        }
                        
                        showTip(tip: result ? "更换地址成功": "更换地址失败", parentView: self.parent?.view ?? self.view, result ? tipColor_bg_success : tipColor_bg_fail, result ? tipColor_text_success : tipColor_text_fail, completion: {})
                    } else {
                        //不做任何事情,始终保持一个被选中
                    }
                }
                break
            case .delete:
                //总要保证有一个配置，不能全部删光
                print("address delete")
                if config.count > 1 {
                    //弹出删除页面
                    if let id = info["id"] as? String {
                        if let item = self.config.first(where: {$0.id == id}) {
                            showDeleteAlert(id: item.id, name: item.name)
                        }
                    }
                } else {
                    showTip(tip: "就一个了,留下吧", parentView: self.parent?.view ?? self.view, tipColor_bg_fail, tipColor_text_fail, completion: {})
                }
                break
            case .modify:
                if let id = info["id"] as? String {
                    if let item = self.config.first(where: {$0.id == id}) {
                        showModifyAlert(info: item)
                    }
                }
                break
            }
        }
    }
    
    //更换地址配置
    private func configAnother(newID: String) -> Bool {
        if self.current != newID {
            if let item = self.config.first(where: {$0.id == newID}) {
                car_UserInfo.cloudarIP = item.cloudarIP
                car_UserInfo.hostID = item.hostID
                self.current = newID
                writeConfig()
                return true
            }
        }
        return false
    }
    //MARK: 展示alert页面
    private func showAddAlert() {
        addAlert = UIAlertController(title: "提示", message: "请填入相关内容", preferredStyle: .alert)
        addAlert?.addTextField() { textField in
            textField.placeholder = "地址配置名称"
        }
        addAlert?.addTextField() { textField in
            textField.placeholder = "云AR主机标识: ABC"
        }
        addAlert?.addTextField() { textField in
            textField.placeholder = "云AR主机IP: 192.168.1.1"
        }
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.addAlert = nil
        }
        addAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let name = self.addAlert?.textFields?[0].text,
               let hostID = self.addAlert?.textFields?[1].text,
               let cloudarIP = self.addAlert?.textFields?[2].text
            {
                self.handleAlertAction(alertType: .add, actionType: .confirm, id: "", info: ["name":name,"hostID": hostID,"cloudarIP":cloudarIP])
            }
        }
        addAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self.view) {
            currController.present(addAlert!, animated: true)
        }
    }
    private func showDeleteAlert(id: String,name: String) {
        deleteAlert = UIAlertController(title: "提示", message: "将删除名称为'\(name)'的地址配置,是否继续?", preferredStyle: .alert)
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.deleteAlert = nil
        }
        deleteAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            self.handleAlertAction(alertType: .delete,actionType: .confirm, id: id, info: [:])
        }
        deleteAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self.view) {
            currController.present(deleteAlert!, animated: true)
        }
    }
    private func showModifyAlert(info: AddressInfo) {
        modifyAlert = UIAlertController(title: "提示", message: "", preferredStyle: .alert)
        modifyAlert?.addTextField { textField in
            textField.placeholder = "地址配置名称"
            textField.text = info.name
        }
        modifyAlert?.addTextField() { textField in
            textField.placeholder = "云AR主机标识: ABC"
            textField.text = info.hostID
        }
        modifyAlert?.addTextField() { textField in
            textField.placeholder = "云AR主机IP: 192.168.1.1"
            textField.text = info.cloudarIP
        }
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.modifyAlert = nil
        }
        modifyAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let name = self.modifyAlert?.textFields?[0].text,
               let hostID = self.modifyAlert?.textFields?[1].text,
               let cloudarIP = self.modifyAlert?.textFields?[2].text
            {
                self.handleAlertAction(alertType: .modify, actionType: .confirm, id: info.id, info: ["id":info.id!,"name":name,"hostID": hostID,"cloudarIP":cloudarIP])
            }
        }
        modifyAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self.view) {
            currController.present(modifyAlert!, animated: true)
        }
    }
}
