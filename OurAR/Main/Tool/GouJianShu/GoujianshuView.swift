//
//  GoujianshuView.swift
//  OurAR
//
//  Created by lee on 2023/7/28.
//

import Foundation
import UIKit
import CloudAR

let gjsIconSize: CGFloat = 20

class GoujianshuView: MTSidebarView , UITableViewDataSource, UITableViewDelegate, GJSCellPtocotol
{

    var searchview: UISearchBar!
    var tableview: UITableView!
    
    //适应链接模型的构件树 string -> projectID或者是自定义构件的uuid; GJSItem -> 该String的最顶层那行,gjsitem的id为 projectID_uuid
    private var topLevelItems_gjs: [GJSItem] = []
    private var focusItem: TreeItem?
    private var showItems: [TreeProtocol] = []
    
    let search_part_height: CGFloat = 50 //搜索和创建栏的整体高度
    let searchHeight: CGFloat = 30 //搜索栏的高度
    
    let tableviewcellIdentifier: String = "vjgjsitemcellid"
    
    init(frame: CGRect) {
        super.init(frame: frame, titleName: "模型浏览器")
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        GJSDelegateManager.add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubView() {
        super.initSubView()
        let search_start_x: CGFloat = left_right_offset
        let search_center_y: CGFloat = headerHeight + search_part_height / 2
        let width = self.bounds.width - left_right_offset * 2
        let padding_with_tag: CGFloat = 5.0
        let searchviewWidth: CGFloat = width - (padding_with_tag + gjsIconSize) * 2
        
        searchview = UISearchBar(frame: CGRect(x: search_start_x, y: 0, width: searchviewWidth, height: searchHeight))
        searchview.center.y = search_center_y
        searchview.placeholder = "请输入你要搜索的内容"
        searchview.backgroundColor = UIColor(white: 1, alpha: 0)
        addSubview(searchview)
        
        let gjsContentviewHeight = self.bounds.height - headerHeight - search_part_height
        let gjsContentviewWidth = self.bounds.width - left_right_offset * 2
        let gjsContentview_center_y = headerHeight + search_part_height + gjsContentviewHeight / 2

        tableview = UITableView(frame: CGRect(x: 0, y: 0, width: gjsContentviewWidth, height: gjsContentviewHeight))
        tableview.center = CGPoint(x: self.bounds.width/2, y: gjsContentview_center_y)
        tableview.register(VJGJSItemCell.self, forCellReuseIdentifier: tableviewcellIdentifier)
        tableview.separatorStyle = .none //隐藏分割线
        tableview.backgroundColor = UIColor(white: 0, alpha: 0)
        addSubview(tableview)
        if getIsIphone() {
            tableview.snp.makeConstraints { make in
                make.top.equalTo(searchview.snp.bottom).offset(10)
                make.left.right.bottom.equalTo(self)
            }
        }
    }
    
    // 实现VJMTSidebarView的函数
    override func handleClose() {
        VJMTDelegateManager.notity(needClosedMainType: .GouJianShu)
    }
    
    func clear() {
        topLevelItems_gjs.removeAll()
        focusItem = nil
        showItems.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: tableviewcellIdentifier, for: indexPath) as? VJGJSItemCell {
            let item = self.showItems[indexPath.row]
            cell.selectionStyle = .none
            // 是否自定义构件
            if let gjsItem = item as? GJSItem {
                cell.hiddenDeleteBtn = !gjsItem.isCustomModel()
            } else {
                cell.hiddenDeleteBtn = true
            }
            
            cell.item = item
            cell.highlight(false)
            if let focusItem = self.focusItem {
                if item._id == focusItem._id {
                    cell.highlight(true)
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }
    
    private func getCellByID(_ id: String) -> VJGJSItemCell? {
        if let row = self.showItems.firstIndex(where: {$0._id == id}) {
            return self.tableview.cellForRow(at: IndexPath(row: row, section: 0)) as? VJGJSItemCell
        }
        return nil
    }
    //MARK: 更新tableview datasource
    private func updateShowItems() {
        var items: [GJSItem] = []
        
        for item in topLevelItems_gjs {
            item.getNeedShowItems(outItems: &items)
        }
        
        showItems = items
        self.tableview.reloadData()
    }
    //MARK: 根据id获得item
    private func getItemByID(_ id: String) -> TreeItem? {
        var target: TreeItem? = nil
        var isFind: Bool = false
        
        for topItem in self.topLevelItems_gjs {
            if !isFind {
                topItem.getItemRecursive(id: id, target: &target, isFind: &isFind)
            } else {
                break
            }
        }
        
        return target
    }
    //MARK: 是否自定义构件
    private func isCustomModel(_ id: String) -> Bool {
        if let gjsItem = getItemByID(id) as? GJSItem {
            return gjsItem.isCustomModel()
        } else {
            return false
        }
        
    }
    //MARK: 根据id获取uuid
    private func getUUIDFromID(_ id: String) -> String {
        let result = id.split(separator: "_")
        if let last = result.last {
            return String(last)
        } else {
            return id
        }
    }
    //MARK: 每次打开Goujianshu页面都要调这个函数
    func open() {
        // 重新打开时，要将focus的item置空
        if let focus = focusItem {
            if let cell = getCellByID(focus._id) {
                cell.highlight(false)
            }
        }
        self.focusItem = nil
        
        // 查询为空
        queryComponentList(uuid: "") {result in
            switch result {
            case .success(let json):
                //NOTICE: 普通模型构件和链接模型构件的区别
                // 记录旧的
                var oldTopLevelItemID: Set<String> = []
                var newTopLevelItemID: Set<String> = []
                for model in self.topLevelItems_gjs {
                    oldTopLevelItemID.insert(model._id)
                }
                // 插入新的
                for one in json {
                    if let name = one["name"] as? String,
                       let uuid = one["uuid"] as? String
                    {
                        //let isCustomModel = uuid == "comp" //用来判断是不是自定义构件层
                        let haveChild = one["haveChild"] as? String ?? "1" //=1有子节点，0无子节点
                        let projectID = one["projectId"] as? String ?? car_UserInfo.currProID
                        let newID = "\(projectID)_\(uuid)"
                        
                        newTopLevelItemID.insert(newID)
                        
                        if let item = self.topLevelItems_gjs.first(where: {$0._id == newID}) {
                            //如果两个uuid相等，但projectid不相等: 删除这个item,替换成另一item
                            if projectID != item.proID {
                                item.deleteSelf()
                                let newGod = GJSItem(id: newID, name: name, type: haveChild == "0" ? .file : .folder, collpase: true, hiddenModel: false)
                                self.topLevelItems_gjs.removeAll(where: {$0._id == newID})
                                self.topLevelItems_gjs.append(newGod)
                                newGod.updateAdditionalInfo(one)
                            } else {
                                print("equal")
                            }
                        } else {
                            print("not equal")
                            let newGod = GJSItem(id: newID, name: name, type: haveChild == "0" ? .file : .folder, collpase: true, hiddenModel: false)
                            self.topLevelItems_gjs.append(newGod)
                            newGod.updateAdditionalInfo(one)
                        }
                    } else {
                        print("\(#function),not found name,uuid ")
                    }
                }
                // 删除不存在的
                let noExistIDs = oldTopLevelItemID.subtracting(newTopLevelItemID)
                self.topLevelItems_gjs.removeAll(where: {noExistIDs.contains($0._id)})
                self.updateShowItems()
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    //MARK: handleCellEvent
    func handleCellEvent(_ id: String, params: [String : Any]) {
        if let type = params["type"] as? GJSCellBtnType {
            switch type {
            case .collpase:
                if let collpase = params["collpase"] as? Bool {
                    if collpase {
                        getItemByID(id)?._collpase = true
                        self.updateShowItems()
                    } else {
                        if let gjsItem = getItemByID(id) as? GJSItem {
                            gjsItem._collpase = false
                            let isCustomModelFolder:Bool = gjsItem.isCustomModel()
                            let needQuery: Bool = isCustomModelFolder ? true : (gjsItem._type == .folder && gjsItem._childrenCount == 0) //是否需要查询: 自定义构件每次都查，模型构件查一次就可以
                            if !needQuery {
                                print("不在需要查询:\(id)")
                                self.updateShowItems()
                            } else {
                                // id != uuid
                                //NOTICE: 这里要将vanjian1234等后缀进行过滤
                                var uuid = getUUIDFromID(id)
                                if uuid.contains("vanjian") {
                                    uuid = "vanjian"
                                }
                                
                                queryComponentList(uuid: uuid,appliId: gjsItem.proID) {result in
                                    switch result {
                                    case .success(let json):
                                        // 再次判断它是否是收缩状态: 这里没有用tagItems是怕还没查询完就又点击了关闭
                                        if let item = self.getItemByID(id) as? GJSItem {
                                            // 如果没有收缩，就要更新
                                            if !item._collpase {
                                                //NOTICE: 这里本应该判断是自定义构件还是模型构件：模型构件不需要进行前后对比，自定义构件需要进行前后对比再把不存在的删除掉
                                                // 但没有做这层判断，我也不知道那个是不是自定义构件
                                                var oldChildItemID: Set<String> = []
                                                var newChildItemID: Set<String> = []
                                                item.getChildrenID(result: &oldChildItemID)
                                                for one in json {
                                                    if let uuid = one["uuid"] as? String,
                                                       let name = one["name"] as? String,
                                                       let haveChild = one["haveChild"] as? String
                                                    {
                                                        let projectID = one["projectId"] as? String ?? car_UserInfo.currProID
                                                        let newID = "\(projectID)_\(uuid)"
                                                        newChildItemID.insert(newID)
                                                        
                                                        // 如果子节点已经存在就更新 名字啥的;如果子节点不存在则插入
                                                        if let child = item.getItemNoRecursive(id: newID) {
                                                            child._name = name
                                                            if let tagChild = child as? GJSItem {
                                                                tagChild.updateAdditionalInfo(one)
                                                            }
                                                        } else {
                                                            // 父节点隐藏 新生成的子节点也要隐藏： 这里的隐藏是模型隐藏
                                                            let newItem = GJSItem(id: newID, name: name, type: haveChild == "0" ? .file : .folder, collpase: true,hiddenModel: item._hiddenModel)
                                                            item.insertChildAtLast(newItem)
                                                            newItem.updateAdditionalInfo(one)
                                                        }
                                                    } else {
                                                        print("not fount uuid name or havechild")
                                                    }
                                                }
                                                // 删除不存在的节点
                                                let noExistIDs = oldChildItemID.subtracting(newChildItemID)
                                                item.deleteChildren(noExistIDs)
                                                //更新tableview的datasource
                                                self.updateShowItems()
                                            } else {
                                                print("本该是展开的，查询结束前又收缩了")
                                            }
                                        }
                                        else {
                                            print("not found item: \(id)")
                                        }
                                        break
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                }
                break
            case .choise:
                var choiseOther = true
                // 取消当前的选中
                if let focus = self.focusItem {
                    getCellByID(focus._id)?.highlight(false)
                    if focus._id == id {
                        self.focusItem = nil
                        choiseOther = false
                    }
                }
                // 选中新的item
                if choiseOther {
                    getCellByID(id)?.highlight(true)
                    self.focusItem = getItemByID(id)
                }
                // 这里的选中要发指令给ue
                let uuid = getUUIDFromID(id)
                if let gjsItem = getItemByID(id) as? GJSItem {
                    if gjsItem.isCustomModel() {
                        sendFocusCostomModel(uuid: uuid,isFoucs: choiseOther, completion: {result in
                            print("focus or not custom model : \(result)")
                        })
                    } else {
                        sendFocusModel(uuid: uuid,appliId:gjsItem.proID,isFoucs: choiseOther,completion: {result in })
                    }
                } else {
                    sendFocusModel(uuid: uuid,isFoucs: choiseOther,completion: {result in })
                }
                break
            case .delete:
                if let item = getItemByID(id) as? GJSItem {
                    if item.isCustomModel() {
                        let uuid = getUUIDFromID(id)
                        sendDeleteCustomModel(uuid: uuid, completion: {result in
                            print("delete custom model : \(id)")
                            // 删除自定义构件要移除相应的item
                            if result {
                                if let focusID = self.focusItem?._id {
                                    if id == focusID {
                                        self.focusItem = nil
                                    }
                                }
                                if let delItem = self.getItemByID(id) as? GJSItem {
                                    delItem.deleteSelf()
                                }
                                if let row = self.topLevelItems_gjs.firstIndex(where: {$0._id == id}) {
                                    self.topLevelItems_gjs.remove(at: row)
                                }
                                self.updateShowItems()
                            }
                        })
                    }
                }
                break
            case .hidden:
                // 这里隐藏的话，旗下的所有子节点都要隐藏
                if let hidden = params["hidden"] as? Bool {
                    if let item = getItemByID(id) {
                        item.hiddenWithRecursive(hidden)
                        self.updateShowItems()
                        // 发指令
                        let uuid = getUUIDFromID(id)
                        if let gjsItem = item as? GJSItem {
                            if gjsItem.isCustomModel() {
                                sendHiddenCustomModel(uuid: uuid, isHidden: hidden, completion: {result in
                                    print("hidden or show custom model:\(result)")
                                })
                            } else {
                                sendHiddenModel(uuid: uuid,appliId: gjsItem.proID,isHidden: hidden, completion: {result in
                                    print("hidden or show model:\(result)")
                                })
                            }
                        } else {
                            sendHiddenModel(uuid: uuid, isHidden: hidden, completion: {result in
                                print("hidden or show model:\(result)")
                            })
                        }
                    }
                }
                break
            }
        }
    }
}
