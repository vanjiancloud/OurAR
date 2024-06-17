//
//  TagView.swift
//  OurAR
//
//  Created by lee on 2023/7/23.
//

import Foundation
import UIKit

fileprivate let tagIconSize: CGFloat = 30
fileprivate enum TagCellBtnType : UInt8
{
    case collpase     = 0
    case choise       = 1
    case focus        = 2
    case modify       = 3
    case delete       = 4
}
//单个标签栏
class TagItemCell: UITableViewCell
{
    fileprivate var updownBtn: UIButton! //上下拉
    fileprivate var tagImg: UIButton!
    fileprivate var label: UILabel! //名称
    fileprivate var bgBtn: UIButton! // 用于点击时模拟选中效果
    fileprivate var modifyBtn: UIButton!
    fileprivate var deleteBtn: UIButton!
    fileprivate var focusBtn: UIButton! //聚焦按钮，文件夹没有这个按钮
    
    fileprivate var highlightImg: UIImageView!
    
    let updownBtnSize: CGFloat = 16.0
    let pad: CGFloat = 5.0
    let levelPad: CGFloat = 10.0
    var left_right_pad: CGFloat = 15.0
    
    var tagItem: TreeProtocol? = nil {
        didSet {
            if let new = tagItem {
                //  如果没有折叠（也就是没有查询子节点）并且 childrenCount == 0，则隐藏上拉下拉图标
                if (!new._collpase && new._childrenCount == 0) || new._type == .file {
                    self.updownBtn.isHidden = true
                } else {
                    self.updownBtn.isHidden = false
                    self.updownBtn.setImage(UIImage(named: new._collpase ? "pullup" : "dropdown"), for: .normal)
                }
                
                //self.updownBtn.isSelected = !new._collpase
                self.bgBtn.setTitle(new._name, for: .normal)
                self.updateLayout()
            } else {
                //self.updownBtn.isSelected = false
                self.label.text = nil
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        updownBtn = UIButton(frame: CGRect(x: 0, y: 0, width: updownBtnSize, height: updownBtnSize))
        updownBtn.center.y = self.bounds.height / 2
        updownBtn.setImage(UIImage(named: "pullup"), for: .normal)
        //updownBtn.setBackgroundImage(UIImage(named: "pullup")?.withRenderingMode(.alwaysTemplate), for: .normal)
        //updownBtn.setBackgroundImage(UIImage(named: "dropdown")?.withRenderingMode(.alwaysTemplate), for: .selected)
        updownBtn.contentMode = .scaleAspectFill
        updownBtn.addAction(UIAction(handler: { _ in
            if let item = self.tagItem {
                if item._type != .file {
                    TCDelegateManager.notity(id: item._id, params: ["type": TagCellBtnType.collpase,"collpase": !item._collpase])
                }
            } else {
                print("tag item is nil")
            }
            
        }), for: .touchUpInside)
        //self.addSubview(updownBtn)
        contentView.addSubview(updownBtn)
        
        let tagImg_start_x = updownBtnSize + pad
        tagImg = UIButton(frame: CGRect(x: tagImg_start_x, y: 0, width: tagIconSize, height: tagIconSize))
        tagImg.center.y = self.bounds.height / 2
        tagImg.setBackgroundImage(UIImage(named: "tagicon"), for: .normal)
        tagImg.contentMode = .scaleAspectFill
        //self.addSubview(tagImg)
        contentView.addSubview(tagImg)
        
        let bg_start_x: CGFloat = tagImg_start_x + tagIconSize + pad
        bgBtn = UIButton(frame: CGRect(x: bg_start_x, y: 0, width: self.bounds.width * 0.4, height: self.bounds.height))
        bgBtn.center.y = self.bounds.height / 2
        bgBtn.setTitle("", for: .normal)
        bgBtn.contentHorizontalAlignment = .left
        bgBtn.titleLabel?.textAlignment = .left
        bgBtn.titleLabel?.font  = .italicSystemFont(ofSize: 20)
        bgBtn.titleLabel?.textColor = .black
        bgBtn.addAction(UIAction(handler: {_ in
            if let item = self.tagItem {
                TCDelegateManager.notity(id: item._id, params: ["type": TagCellBtnType.choise])
            } else {
                print("tag item is nil")
            }
        }), for: .touchUpInside)
        contentView.addSubview(bgBtn)
        
        let delete_center_x: CGFloat = self.bounds.width - tagIconSize / 2 - left_right_pad
        deleteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: tagIconSize, height: tagIconSize))
        deleteBtn.center = CGPoint(x: delete_center_x, y: self.bounds.height / 2)
        deleteBtn.contentMode = .scaleAspectFill
        deleteBtn.setBackgroundImage(UIImage(named: "delete"), for: .normal)
        deleteBtn.addAction(UIAction(handler: {_ in
            if let item = self.tagItem {
                TCDelegateManager.notity(id: item._id, params: ["type": TagCellBtnType.delete,"name":item._name])
            } else {
                print("tag item is nil")
            }
        }), for: .touchUpInside)
        //self.addSubview(deleteBtn)
        contentView.addSubview(deleteBtn)
        
        let modify_center_x: CGFloat = self.bounds.width - tagIconSize * 1.5 - pad - left_right_pad
        modifyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: tagIconSize, height: tagIconSize))
        modifyBtn.center = CGPoint(x: modify_center_x, y: self.bounds.height / 2)
        modifyBtn.setBackgroundImage(UIImage(named: "modify"), for: .normal)
        modifyBtn.contentMode = .scaleAspectFill
        modifyBtn.addAction(UIAction(handler: {_ in
            if let item = self.tagItem {
                TCDelegateManager.notity(id: item._id, params: ["type": TagCellBtnType.modify,"name": item._name])
            } else {
                print("tag item is nil")
            }
        }), for: .touchUpInside)
        //暂时不添加到subview中
        //self.addSubview(modifyBtn)
        contentView.addSubview(modifyBtn)
        
        let focus_center_x: CGFloat = self.bounds.width - tagIconSize * 2.5 - pad * 2 - left_right_pad
        focusBtn = UIButton(frame: CGRect(x: 0, y: 0, width: tagIconSize, height: tagIconSize))
        focusBtn.center = CGPoint(x: focus_center_x, y: self.bounds.height / 2)
        focusBtn.setBackgroundImage(UIImage(named: "focus"), for: .normal)
        focusBtn.contentMode = .scaleAspectFill
        focusBtn.addAction(UIAction(handler: {_ in
            if let item = self.tagItem {
                TCDelegateManager.notity(id: item._id, params: ["type": TagCellBtnType.focus])
            } else {
                print("tag item is nil")
            }
        }),for: .touchUpInside)
        //暂时不添加到subview中
        //self.addSubview(focusBtn)
        contentView.addSubview(focusBtn)
        
        highlightImg = UIImageView(frame: CGRect(x: updownBtnSize + pad, y: 0, width: self.bounds.width - updownBtnSize-pad, height: self.bounds.height))
        contentView.insertSubview(highlightImg, at: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 更新布局
    private func updateLayout() {
        if let treeProtocol = tagItem {
            // 制造出一种层次感
            let level = treeProtocol._level
            let focusBtnHidden = treeProtocol._type != .file
            
            if focusBtnHidden {
                focusBtn.removeFromSuperview()
            } else {
                if !self.contentView.subviews.contains(focusBtn) {
                    self.contentView.addSubview(focusBtn)
                }
            }
            
            let updown_center_x: CGFloat = CGFloat(level) * levelPad + updownBtnSize / 2
            let tagImg_center_x: CGFloat = updown_center_x + pad + tagIconSize / 2 + updownBtnSize / 2
            
            let bgBtn_width: CGFloat = (focusBtnHidden ? modifyBtn.center.x : focusBtn.center.x) - tagImg_center_x - tagIconSize
            let bgBtn_center_x: CGFloat = tagImg_center_x + tagIconSize / 2 + 5 + bgBtn_width / 2
            
            updownBtn.center.x = updown_center_x
            tagImg.center.x = tagImg_center_x
           
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

class TagView : MTSidebarView, UITableViewDataSource, UITableViewDelegate, TagCellPtocotol, TagModifyActionProtocol, TagDeleteActionProtocol
{
    
    var searchview: UISearchBar!
    var createTagBtn: UIButton!
    var createFolderBtn: UIButton!
    var scrollview: UIScrollView! //滑动部分
    var tableview: UITableView!
    
    let search_part_height: CGFloat = 50 //搜索和创建栏的整体高度
    let searchHeight: CGFloat = 30 //搜索栏的高度
    
    //let tagIconSize: CGFloat = 25 //tag所有图标的大小：包括create
    
    // TreeItem设置为class, 引用类型比较方便处理迭代循环
    private var topLevelItems: [TagItem] = [] //最顶层的文件或文件夹,每次新建都是插入在首位
    private var focusTagItem: TreeItem? //所聚焦的tagitem,如果有聚焦的，那创建新的文件夹或标签都是在它层级中创建;如果没有聚焦的，就是在最顶层的目录创建
    private var showItems: [TreeProtocol] = [] //所有要展示出来的数据
    
    var deleteAlert: UIAlertController? //删除的Alert
    var modifyAlert: UIAlertController?
    
    init(frame: CGRect) {
        super.init(frame: frame, titleName: "标签")
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        TCDelegateManager.add(self)
    }
    
    deinit {
        TCDelegateManager.remove(self)
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
        let searchviewWidth: CGFloat = width - (padding_with_tag + tagIconSize) * 2
        
        searchview = UISearchBar(frame: CGRect(x: search_start_x, y: 0, width: searchviewWidth, height: searchHeight))
        searchview.center.y = search_center_y
        searchview.placeholder = "请输入你要搜索的内容"
        searchview.backgroundColor = UIColor(white: 1, alpha: 0)
        addSubview(searchview)
        
        let createTagBtn_start_x = search_start_x + searchviewWidth + padding_with_tag
        createTagBtn = UIButton(frame: CGRect(x: createTagBtn_start_x, y: 0, width: tagIconSize, height: tagIconSize))
        createTagBtn.center.y = search_center_y
        createTagBtn.setBackgroundImage(UIImage(named: "createTag"), for: .normal)
        createTagBtn.addAction(UIAction(handler: {_ in
            self.handleCreateTag()
        }), for: .touchUpInside)
        addSubview(createTagBtn)
        
        let createFolderBtn_start_x = createTagBtn_start_x + tagIconSize + padding_with_tag
        createFolderBtn = UIButton(frame: CGRect(x: createFolderBtn_start_x, y: 0, width: tagIconSize, height: tagIconSize))
        createFolderBtn.center.y = search_center_y
        createFolderBtn.setBackgroundImage(UIImage(named: "createTagFolder"), for: .normal)
        createFolderBtn.addAction(UIAction(handler: {_ in
            self.handleCreateTagFolder()
        }), for: .touchUpInside)
        addSubview(createFolderBtn)
        
        let tagContentviewHeight = self.bounds.height - headerHeight - search_part_height
        let tagContentviewWidth = self.bounds.width - left_right_offset * 2
        let tagContentview_center_y = headerHeight + search_part_height + tagContentviewHeight / 2

        tableview = UITableView(frame: CGRect(x: 0, y: 0, width: tagContentviewWidth, height: tagContentviewHeight))
        tableview.center = CGPoint(x: self.bounds.width/2, y: tagContentview_center_y)
        tableview.register(TagItemCell.self, forCellReuseIdentifier: "vjtagitemcellid")
        tableview.separatorStyle = .none //隐藏分割线
        tableview.backgroundColor = UIColor(white: 0, alpha: 0)
        addSubview(tableview)
        
    }
    
    override func handleClose() {
        VJMTDelegateManager.notity(needClosedMainType: .BiaoQian)
        
        if let focusItem = focusTagItem {
            if let cell = getTagCellByID(focusItem._id) {
                cell.highlight(false)
            }
        }
        self.focusTagItem = nil
    }
    
    func clear() {
        topLevelItems.removeAll()
        focusTagItem = nil
        showItems.removeAll()
    }
    
    // 所focus的item是否能够在此创建file or folder
    private func canCreateInFocusItem() -> Bool {
        if let focus = focusTagItem {
            if !focus.canAddChild() {
                let parentView = getControllerOfSubview(self)?.view ?? self
                showTip(tip: "请先选择标签组", parentView: parentView, center: CGPoint(x: parentView.bounds.width/2, y: parentView.bounds.height*0.2), tipColor_bg_warning, tipColor_text_warning, completion: {})
                return false
            }
        }
        return true
    }
    // 将新创建的文件或文件夹插入到数据源中去
    /*
     newItem: 新创建的item
     groupID: 所属的组ID，为空的话，就是最顶层
     topID: 所属的组的最顶层的ID，
     groupCollpase: 所属的组是否收缩或展开
     */
    private func insertNewItem(newItem: TagItem,groupID: String,topID: String) {
        var groupItem: TreeItem? = nil
        
        // 查找groupItem， 为啥不直接用focusItem，focusItem在请求返回前会变，这里根据groupId来查找
        let currFocuID = self.focusTagItem?._id ?? ""
        if !groupID.isEmpty {
            if currFocuID == groupID {
                groupItem = self.focusTagItem
            } else {
                groupItem = self.getTagItemByID(topID: topID, targetID: groupID)
            }
        }
        
        // 将newItem插入到groupItem的children中: 有groupid不为空则插入到group，为空则插入到top
        if !groupID.isEmpty {
            if let group = groupItem {
                group.insertChild(newItem, at: 0)
            } else {
                print("本应该有groupid，但没找到该group")
            }
        } else {
            self.topLevelItems.insert(newItem, at: 0)
        }
        
        // 更新tableview:
        // 如果groupid不为空，groupitem collpase = false，则要展示newitem，collpase = true，则不展示
        // 如果grouid为空，则展示newitem
        let needInsertToTableView = groupID.isEmpty ? true : (groupItem == nil ? false : !groupItem!._collpase)
        
        if needInsertToTableView {
            // 查找待插入的位置
            var row  = 0
            if let groupRow = self.showItems.firstIndex(where: {$0._id == groupID }) {
                row = groupRow + 1
            } else if !groupID.isEmpty {
                // 应该提示错误
                // tagItem中没有找到groupitem对应的id
                print("tag items中没有找到groupitem对应的id")
            }
            self.showItems.insert(newItem, at: row)
            self.tableview.beginUpdates()
            if row != 0 { self.tableview.reloadRows(at: [IndexPath(row: row-1, section: 0)], with: .none)} //如果是在group中插入则要刷新下groupid对应的一栏
            self.tableview.insertRows(at: [IndexPath(row: row, section: 0)], with: .right)
            self.tableview.endUpdates()
        }
    }
    // 处理标签的创建
    private func handleCreateTag() {
        //能否创建标签
        if !canCreateInFocusItem() { return }
        
        let groupID = focusTagItem?._id ?? ""
        let topID = focusTagItem?.getTopID() ?? ""
        
        createTagFile(tagGroupID: groupID) { result in
            switch result {
            case .success(let id):
                let newItem = TagItem(_id: id, _name: "默认标签", _type: .file, _collpase: false)
                self.insertNewItem(newItem: newItem, groupID: groupID, topID: topID)
            case .failure(let error):
                print("\(#function),\(error)")
                showTip(tip: "\(error)", parentView: getControllerOfSubview(self).view, center: CGPoint(x: self.bounds.width/2, y: self.bounds.height*0.2), tipColor_bg_fail, tipColor_text_fail, completion: {})
            }
        }
    }
    // 处理标签文件夹的创建
    private func handleCreateTagFolder() {
        if !canCreateInFocusItem() { return }
        
        let groupID = focusTagItem?._id ?? ""
        let topID = focusTagItem?.getTopID() ?? ""
       
        createTagFolder(tagGroupID: groupID){ result in
            switch result {
            case .success(let id):
                let newItem = TagItem(_id: id, _name: "默认标签组", _type: .folder, _collpase: true)
                self.insertNewItem(newItem: newItem, groupID: groupID, topID: topID)
            case .failure(let error):
                print(error)
                showTip(tip: "\(error)", parentView: getControllerOfSubview(self).view, center: CGPoint(x: self.bounds.width/2, y: self.bounds.height*0.2), tipColor_bg_fail, tipColor_text_fail, completion: {})
            }
        }
    }
    
    //MARK: TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "vjtagitemcellid", for: indexPath) as? TagItemCell {
            let tagItem = self.showItems[indexPath.row]
            cell.selectionStyle = .none
            cell.tagItem = tagItem
            cell.highlight(false)
            if let focusItem = self.focusTagItem {
                if tagItem._id == focusItem._id {
                    cell.highlight(true)
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    
    private func getTagItemByID(topID: String,targetID: String) -> TreeItem? {
        if topID.isEmpty || targetID.isEmpty {
            return nil
        }
        var target: TreeItem? = nil
        var isFind: Bool = false
        if let item = topLevelItems.first(where: {$0._id == topID}) {
            item.getItemRecursive(id: targetID, target: &target, isFind: &isFind)
        }
        return target
    }
    
    private func getTagItemByID(targetID: String) -> TreeItem? {
        var target: TreeItem? = nil
        var isFind: Bool = false
        for topItem in topLevelItems {
            topItem.getItemRecursive(id: targetID, target: &target, isFind: &isFind)
        }
        return target
    }
    
    //MARK: open
    func open() {
        // 每次打开都需要初始化一些参数
        if let focusItem = focusTagItem {
            if let cell = getTagCellByID(focusItem._id) {
                cell.highlight(false)
            }
        }
        self.focusTagItem = nil
        
        // 每次打开都只查询最顶层的数据
        queryTagList(tagGroupID: "") { result in
            switch result {
            case .success(let json):
                var needUpdateTableView = false
                
                var oldTopLevelItemID: Set<String> = []
                var newTopLevelItemID: Set<String> = []
                for item in self.topLevelItems {
                    oldTopLevelItemID.insert(item._id)
                }
                //print(json)
                
                //增加新的或修改原来的
                for one in json {
                    if let id = one["id"] as? String,
                       let fileName = one["fileName"] as? String,
                       let isFolder = one["isFolder"] as? String
                    {
                        newTopLevelItemID.insert(id)
                        //存在就更新
                        if let item = self.topLevelItems.first(where: {$0._id == id}) {
                            if item._name != fileName {
                                needUpdateTableView =  true
                                item._name = fileName
                            }
                            item.updateAdditionalInfo(one)
                        } else {
                            //不存在就创建
                            let newItem = TagItem(_id: id, _name: fileName, _type: isFolder == "0" ? .file : .folder, _collpase: true)
                            self.topLevelItems.insert(newItem, at: 0)
                            newItem.updateAdditionalInfo(one)
                            needUpdateTableView = true
                        }
                    }
                }
                //删除不存在的
                let noExistIDs = oldTopLevelItemID.subtracting(newTopLevelItemID)
                self.topLevelItems.removeAll(where: { noExistIDs.contains($0._id) })
                if !noExistIDs.isEmpty { needUpdateTableView = true }
                
                //更新tablveview数据源
                if needUpdateTableView {
                    self.updateShowItems()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: 更新tableview datasource
    private func updateShowItems() {
        var items: [TreeProtocol] = []
        for tag in topLevelItems {
            tag.getNeedShowItems(outItems: &items)
        }
        showItems = items
        self.tableview.reloadData()
    }
    
    private func getTagCellByID(_ id: String) -> TagItemCell?{
        if let row = self.showItems.firstIndex(where: {$0._id == id}) {
            return self.tableview.cellForRow(at: IndexPath(row: row, section: 0)) as? TagItemCell
        }
        return nil
    }
    
    //MARK: 监听TagCell btn的动作
    func handleCellEvent(_ id: String, params: [String : Any]) {
        if let type = params["type"] as? TagCellBtnType {
            print(type)
            switch type {
            case .collpase:
                // collpase：false 则收缩，true则要进行查询以便进行更新
                if let collpase = params["collpase"] as? Bool {
                    if collpase {
                        getTagCellByID(id)?.tagItem?._collpase = true
                        //更新tableview的datasource
                        self.updateShowItems()
                    } else {
                        //这里没有再去判断id是不是一个groupid，因为button触发的时候判断过了，就不再再次判断
                        getTagCellByID(id)?.tagItem?._collpase = false
                        queryTagList(tagGroupID: id) {result in
                            switch result {
                            case .success(let json):
                                // 再次判断它是否是收缩状态: 这里没有用tagItems是怕还没查询完就又点击了关闭
                                if let item = self.getTagItemByID(targetID: id) {
                                    // 如果没有收缩就把新数据更新进去
                                    if !item._collpase {
                                        
                                        var oldChildItemID: Set<String> = []
                                        var newChildItemID: Set<String> = []
                                        item.getChildrenID(result: &oldChildItemID)
                                        
                                        for one in json {
                                            if let childID = one["id"] as? String,
                                               let fileName = one["fileName"] as? String,
                                               let isFolder = one["isFolder"] as? String
                                            {
                                                newChildItemID.insert(childID)
                                                // 如果子节点已经存在就更新 名字啥的;如果子节点不存在则插入
                                                if let child = item.getItemNoRecursive(id: childID) {
                                                    child._name = fileName
                                                    if let tagChild = child as? TagItem {
                                                        tagChild.updateAdditionalInfo(one)
                                                    }
                                                } else {
                                                    let newItem = TagItem(_id: childID, _name: fileName, _type: isFolder == "0" ? .file : .folder, _collpase: true)
                                                    item.insertChildAtLast(newItem)
                                                    newItem.updateAdditionalInfo(one)
                                                }
                                            }
                                        }
                                        //删除不存在子节点
                                        let noExistIDs = oldChildItemID.subtracting(newChildItemID)
                                        item.deleteChildren(noExistIDs)
                                        //更新tableview的datasource
                                        self.updateShowItems()
                                    }
                                }
                                break
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
                break
            case .choise:
                var choiseOther = true
                // 取消当前的选中
                if let focusItem = self.focusTagItem {
                    getTagCellByID(focusItem._id)?.highlight(false)
                    if focusItem._id == id {
                        self.focusTagItem = nil
                        choiseOther = false
                    }
                }
                // 选中新的item
                if choiseOther {
                    getTagCellByID(id)?.highlight(true)
                    self.focusTagItem = getTagItemByID(targetID: id)
                }
                break
            case .focus:
                // TODO: 发送聚焦
                handelTagFocusAction(tagID: id) { (isSuccess,msg) in
                    if isSuccess {
                        print("定位成功")
                    } else {
                        print(msg)
                    }
                }
                break
            case .modify:
                if let name = params["name"] as? String {
                    if let _ = getControllerOfSubview(self) {
                        showModifyAlert(name: name,id: id)
                    }
                } else { print("modify params not found name")}
                break
            case .delete:
                if let _ = getControllerOfSubview(self),
                   let name = params["name"] as? String
                {
                    showDeleteAlert(name: name, id: id)
                }
                break
            }
        }
    }
    
    //MARK: tagModify页面的代理方法
    func handleTagModifyViewAction(type: TagAlertActionType, params: [String : Any]) {
        switch type {
        case .cancel:
            break
        case .confirm:
            if let newName = params["name"] as? String,
               let id = params["id"] as? String
            {
                updateTagName(tagID: id, name: newName) { (isSuccess,msg) in
                    if isSuccess {
                        // 如果删除的是focusItem
                        if let focusItem = self.focusTagItem {
                            if focusItem._id == id {
                                self.focusTagItem = nil
                            }
                        }
                        // 更新原始数据
                        if let item = self.getTagItemByID(targetID: id) {
                            item._name = newName
                        }
                        // 更新tableview中de
                        if let cell = self.getTagCellByID(id) {
                            cell.tagItem?._name = newName
                            self.tableview.beginUpdates()
                            if let row = self.showItems.firstIndex(where: {$0._id == id}) {
                                self.tableview.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                            }
                            self.tableview.endUpdates()
                        }
                    } else {
                        print(msg)
                    }
                }
                
            } else {
                print("confirm modify action,not found id or name")
            }
        }
    }
    
    //MARK: tagDelete页面的代理方法
    func handleTagDeleteViewAction(type: TagAlertActionType, id: String) {
        switch type {
        case .cancel:
            break
        case .confirm:
            deleteTag(tagID: id) { (isSuccess,msg) in
                if isSuccess {
                    // 是不是focusItem
                    if let focusID = self.focusTagItem?._id {
                        if id == focusID {
                            self.focusTagItem = nil
                        }
                    }
                    // 删除原始数据
                    if let item = self.getTagItemByID(targetID: id) {
                        item.deleteSelf()
                    }
                    // 看是否是topItem: 为什么要考虑topItem,而不是其他childItem，我也不知道
                    if let row = self.topLevelItems.firstIndex(where: {$0._id == id}) {
                        self.topLevelItems.remove(at: row)
                    }
                    // 删除tableview中的
                    self.updateShowItems()
                } else {
                    print(msg)
                }
            }
            break
        }
    }
    
    private func showModifyAlert(name: String,id: String) {
        modifyAlert = UIAlertController(title: "提示", message: "", preferredStyle: .alert)
        modifyAlert?.addTextField { textField in
            textField.placeholder = name
        }
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.modifyAlert = nil
        }
        modifyAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let inputText = self.modifyAlert?.textFields?.first?.text {
                self.handleTagModifyViewAction(type: .confirm, params: ["name":inputText,"id":id])
            }
        }
        modifyAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self) {
            currController.present(modifyAlert!, animated: true)
        }
    }
    
    private func showDeleteAlert(name:String,id: String) {
        deleteAlert = UIAlertController(title: "提示", message: "将删除名称为'\(name)'的数据,是否继续?", preferredStyle: .alert)
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.deleteAlert = nil
        }
        deleteAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            self.handleTagDeleteViewAction(type: .confirm, id: id)
        }
        deleteAlert?.addAction(okAction)
        
        if let currController = getControllerOfSubview(self) {
            currController.present(deleteAlert!, animated: true)
        }
    }
}
