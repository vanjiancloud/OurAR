//
//  ServerSettingController.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation
import UIKit
import CloudAR

class ServerSettingController: UIViewController, UITableViewDataSource, UITableViewDelegate,SettingProtocol,SettingAlertProtocol
{
    var config: [ServerInfo] = []
    var current: String!
    private let fileName = "server"
    
    var settingView: ServerAddressSettingView!
    
    var deleteAlert: UIAlertController?
    var modifyAlert: UIAlertController?
    var addAlert: UIAlertController?
    
    private let httpButton = UIButton(type: .custom)
    private let httpsButton = UIButton(type: .custom)
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        settingView = ServerAddressSettingView(frame: frame, type: .server)
        self.view = settingView
        settingView.settingProtocol = self
        settingView.backgroundColor = .none
        settingView.table.dataSource = self
        settingView.table.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("setting frame: \(settingView.bounds)")
    }
    
    func initConfig() {
        var hasConfig = 0
        self.config.removeAll()
        if existOfFile(fileName: fileName, extension: .txt) {
            if let content = readFile(name: fileName, extension: .txt) {
                if let data = content.data(using: .utf8) {
                    if let json = car_dataToJson(from: data),
                       let currentID = json["current"] as? String,
                       let list = json["list"] as? [[String:Any]]
                    {
                        self.current = currentID
                        list.forEach{(item) in
                            if let javaServer = item["javaServer"] as? String,
                               let cloudServer = item["cloudServer"] as? String,
                               let javaWS = item["javaWS"] as? String,
                               let name = item["name"] as? String,
                               let id = item["id"] as? String
                            {
                                let server = ServerInfo()
                                server.id = id
                                server.name = name
                                server.javaServer = javaServer
                                server.cloudServer = cloudServer
                                server.javaWS = javaWS
                                config.append(server)
                                
                                hasConfig = hasConfig | (id == self.current ? 1 : 0)
                            }
                        }
                    }
                }
            }
        }
        
        if hasConfig == 0 {
            let baseServer = ServerInfo()
            baseServer.javaServer = car_URL.urlPre
            baseServer.cloudServer = car_URL.xrUrlPre
            if (car_URL.javaWS.isEmpty) {
                car_URL.javaWS = "wss://api.ourbim.com:11023/vjapi"
            }
            baseServer.javaWS = car_URL.javaWS
            baseServer.name = "默认服务配置"
            self.current = baseServer.id
            self.config.append(baseServer)
            writeConfig()
            print("配置中未有server info")
        } else {
            if let item = self.config.first(where: {$0.id == self.current}) {
                car_URL.javaWS = item.javaWS
                car_URL.urlPre = item.javaServer
                car_URL.xrUrlPre = item.cloudServer
                print("从配置中初始化server info,url: \(car_URL.urlPre),xrurl: \(car_URL.xrUrlPre),ws: \(car_URL.javaWS)")
            }
        }
    }
    
    private func writeConfig() {
        print("write server config")
        var info: [String:Any] = [:]
        var list: [[String:Any]] = []
        info["current"] = self.current
        config.forEach{(item) in
            guard let id = item.id,
                  let name = item.name,
                  let javaServer = item.javaServer,
                  let cloudServer = item.cloudServer,
                  let javaWS = item.javaWS else {
                print("Missing required field in config item: \(item)")
                return
            }
            
            let one: [String:Any] = [
                "id": id,
                "name": name,
                "javaServer": javaServer,
                "cloudServer": cloudServer,
                "javaWS": javaWS
            ]
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
            cell.settingInfo = (SettingType.server,config[indexPath.row].id,config[indexPath.row].name)
            cell.settingProtocol = self
            cell.choice(self.current == config[indexPath.row].id)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }
    
    func handleAlertAction(alertType: SettingAlertType,actionType: SettingAlertActionType, id: String, info: [String : Any]) {
        switch alertType {
        case .add:
            switch actionType {
            case .cancel:
                break
            case .confirm:
                if let name = info["name"] as? String,
                   let javaServer = info["javaServer"] as? String,
                   let cloudServer = info["cloudServer"] as? String,
                   let javaWS = info["javaWS"] as? String
                {
                    let new = ServerInfo()
                    new.name = name
                    new.javaServer = javaServer
                    new.cloudServer = cloudServer
                    new.javaWS = javaWS
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
                
                if self.current == id  && self.config.count > 0{
                    if let item = self.config.first {
                        self.current = item.id
                        car_URL.javaWS = item.javaWS
                        car_URL.xrUrlPre = item.cloudServer
                        car_URL.urlPre = item.javaServer
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
                   let javaServer = info["javaServer"] as? String,
                   let cloudServer = info["cloudServer"] as? String,
                   let javaWS =  info["javaWS"] as? String
                {
                    if let row = self.config.firstIndex(where: {$0.id == id}) {
                        self.config.first(where: {$0.id == id})?.update(name: name, javaServer: javaServer,cloudServer: cloudServer,javaWS: javaWS )
                        self.settingView.table?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                        
                        if self.current == id {
                            car_URL.javaWS =  javaWS
                            car_URL.urlPre = javaServer
                            car_URL.xrUrlPre = cloudServer
                        }
                        
                        writeConfig()
                    }
                }
            }
            break
        }
    }
    
    func handleSetting(type: SettingType, action: SettingActionType, info: [String : Any]) {
        if type == .server {
            switch action {
            case .add:
                showAddAlert()
                break
            case .choice:
                if let id = info["id"] as? String {
                    if self.current != id {
                        let oldCurr  = self.current
                        let result = configAnother(newID: id)
                        
                        if result {
                            if let oldRow = config.firstIndex(where: {$0.id == oldCurr}),
                               let newRow = config.firstIndex(where: {$0.id == id})
                            {
                                let oldCell = settingView.table.cellForRow(at: IndexPath(row: oldRow, section: 0)) as? ServerAddressSettingCell
                                let newCell = settingView.table.cellForRow(at: IndexPath(row: newRow, section: 0)) as? ServerAddressSettingCell
                                oldCell?.choice(false)
                                newCell?.choice(true)
                            }
                        }
                        
                        showTip(tip: result ? "更换服务成功": "更换服务失败", parentView: self.parent?.view ?? view, result ? tipColor_bg_success : tipColor_bg_fail, result ? tipColor_text_success : tipColor_text_fail, completion: {})
                    }
                }
                break
            case .delete:
                print("server delete")
                if config.count > 1 {
                    if let id = info["id"] as? String {
                        if let item = config.first(where: {$0.id == id}) {
                            showDeleteAlert(id: item.id, name: item.name)
                        }
                    }
                } else {
                    showTip(tip: "就一个了,留下吧", parentView: parent?.view ?? view, tipColor_bg_fail, tipColor_text_fail, completion: {})
                }
                break
            case .modify:
                if let id = info["id"] as? String {
                    if let item = config.first(where: {$0.id == id}) {
                        showModifyAlert(info: item)
                    }
                }
                break
            }
        }
    }
    
    private func configAnother(newID: String) -> Bool {
        if self.current != newID {
            if let item = self.config.first(where: {$0.id == newID}) {
                car_URL.javaWS = item.javaWS
                car_URL.urlPre = item.javaServer
                car_URL.xrUrlPre = item.cloudServer
                self.current = newID
                writeConfig()
                return true
            }
        }
        return false
    }
    
    // MARK: - 新增弹窗（修复完成）
    private func showAddAlert() {
        addAlert = UIAlertController(title: "提示\n\n", message: "", preferredStyle: .alert)
        
        addProtocolSelectorView(to: addAlert!)
        
        addAlert?.addTextField() { textField in
            textField.placeholder = "服务配置名称"
        }
        addAlert?.addTextField() { textField in
            textField.placeholder = "后端服务: xx.xx.xx:1"
        }
        addAlert?.addTextField() { textField in
            textField.placeholder = "XR服务: xx.xx.xx:2"
        }
        addAlert?.addTextField() { textField in
            textField.placeholder = "WebSocket: xx.xx.xx:3"
        }
        
        self.httpButton.isSelected = true
        self.httpsButton.isSelected = false
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        addAlert?.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            guard let name = self.addAlert?.textFields?[0].text,
                  let serverRaw = self.addAlert?.textFields?[1].text,
                  let xrRaw = self.addAlert?.textFields?[2].text,
                  let wsRaw = self.addAlert?.textFields?[3].text else { return }
            
            let isHttp = self.httpButton.isSelected
            let httpPre = isHttp ? "http://" : "https://"
            let wsPre = isHttp ? "ws://" : "wss://"
            
            // ✅ 【正确拼接】和你项目完全匹配
            let javaServer  = "\(httpPre)\(serverRaw)/vjapi/"
            let cloudServer = "\(httpPre)\(xrRaw)/api/"
            let javaWS      = "\(wsPre)\(wsRaw)/vjapi"
            
            self.handleAlertAction(alertType: .add, actionType: .confirm, id: "", info: [
                "name": name,
                "javaServer": javaServer,
                "cloudServer": cloudServer,
                "javaWS": javaWS
            ])
        }
        addAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self.view) {
            currController.present(addAlert!, animated: true)
        }
    }
    
    // MARK: - 修改弹窗（修复完成）
    private func showModifyAlert(info: ServerInfo) {
        modifyAlert = UIAlertController(title: "提示\n\n", message: "", preferredStyle: .alert)
        
        addProtocolSelectorView(to: modifyAlert!)
        
        let isCurrentHttp = info.javaServer?.contains("http://") ?? false
        httpButton.isSelected = isCurrentHttp
        httpsButton.isSelected = !isCurrentHttp
        
        modifyAlert?.addTextField { textField in
            textField.text = info.name
        }
        modifyAlert?.addTextField() { textField in
            textField.text = self.pureAddress(info.javaServer)
        }
        modifyAlert?.addTextField() { textField in
            textField.text = self.pureAddress(info.cloudServer)
        }
        modifyAlert?.addTextField() { textField in
            textField.text = self.pureAddress(info.javaWS)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        modifyAlert?.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            guard let name = self.modifyAlert?.textFields?[0].text,
                  let serverRaw = self.modifyAlert?.textFields?[1].text,
                  let xrRaw = self.modifyAlert?.textFields?[2].text,
                  let wsRaw = self.modifyAlert?.textFields?[3].text else { return }
            
            let isHttp = self.httpButton.isSelected
            let httpPre = isHttp ? "http://" : "https://"
            let wsPre = isHttp ? "ws://" : "wss://"
            
            // ✅ 【正确还原】完全匹配你项目真实地址
            let javaServer  = "\(httpPre)\(serverRaw)/vjapi/"
            let cloudServer = "\(httpPre)\(xrRaw)/api/"
            let javaWS      = "\(wsPre)\(wsRaw)/vjapi"
            
            self.handleAlertAction(alertType: .modify, actionType: .confirm, id: info.id ?? "", info: [
                "id": info.id ?? "",
                "name": name,
                "javaServer": javaServer,
                "cloudServer": cloudServer,
                "javaWS": javaWS
            ])
        }
        modifyAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self.view) {
            currController.present(modifyAlert!, animated: true)
        }
    }
    
    // MARK: - 协议按钮
    private func addProtocolSelectorView(to alert: UIAlertController) {
        let container = UIView(frame: CGRect(x: 20, y: 50, width: 300, height: 40))
        container.backgroundColor = .clear
        
        httpButton.setTitle("  http", for: .normal)
        httpsButton.setTitle("  https", for: .normal)
        
        httpButton.setTitleColor(UIColor(red: 0x46/255, green: 0x4C/255, blue: 0x5E/255, alpha: 1.0), for: .normal)
        httpButton.setTitleColor(UIColor(red: 0x47/255, green: 0xC0/255, blue: 0xFF/255, alpha: 1.0), for: .selected)

        httpsButton.setTitleColor(UIColor(red: 0x46/255, green: 0x4C/255, blue: 0x5E/255, alpha: 1.0), for: .normal)
        httpsButton.setTitleColor(UIColor(red: 0x47/255, green: 0xC0/255, blue: 0xFF/255, alpha: 1.0), for: .selected)
        
        httpButton.setImage(UIImage(named: "img_noSelect"), for: .normal)
        httpButton.setImage(UIImage(named: "img_select"), for: .selected)
        httpsButton.setImage(UIImage(named: "img_noSelect"), for: .normal)
        httpsButton.setImage(UIImage(named: "img_select"), for: .selected)
        
        httpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        httpsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        httpButton.addTarget(self, action: #selector(protocolBtnTapped(_:)), for: .touchUpInside)
        httpsButton.addTarget(self, action: #selector(protocolBtnTapped(_:)), for: .touchUpInside)
        
        httpButton.isSelected = true
        
        container.addSubview(httpButton)
        container.addSubview(httpsButton)
        
        httpButton.frame = CGRect(x: 20, y: 5, width: 80, height: 30)
        httpsButton.frame = CGRect(x: 180, y: 5, width: 100, height: 30)
        
        alert.view.addSubview(container)
    }
    
    @objc private func protocolBtnTapped(_ sender: UIButton) {
        httpButton.isSelected = (sender == httpButton)
        httpsButton.isSelected = (sender == httpsButton)
    }
    
    // MARK: - 地址净化（显示用）
    private func pureAddress(_ str: String?) -> String {
        guard let s = str else { return "" }
        return s.replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "ws://", with: "")
            .replacingOccurrences(of: "wss://", with: "")
            .replacingOccurrences(of: "/api/", with: "")
            .replacingOccurrences(of: "/vjapi/", with: "")
            .replacingOccurrences(of: "/vjapi", with: "")
            .replacingOccurrences(of: "/", with: "")
    }
    
    // MARK: - 删除弹窗
    private func showDeleteAlert(id: String,name: String) {
        deleteAlert = UIAlertController(title: "提示", message: "将删除名称为'\(name)'的服务配置,是否继续?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.deleteAlert = nil
        }
        deleteAlert?.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            self.handleAlertAction(alertType: .delete,actionType: .confirm, id: id, info: [:])
        }
        deleteAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self.view) {
            currController.present(deleteAlert!, animated: true)
        }
    }
}
