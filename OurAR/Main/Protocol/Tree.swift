//
//  Tree.swift
//  OurAR
//
//  Created by lee on 2023/7/23.
//

import Foundation

protocol TreeProtocol
{
    var _id: String {get} //id
    var _name: String {get set}//名称
    var _type: FileType {get}//类型
    var _collpase: Bool {get set}//是否收缩
    var _level: Int {get} //层级
    var _childrenCount: Int {get} // 子节点的数量
    var _hiddenModel: Bool { get set} //模型隐藏
}

extension TreeProtocol {
    mutating func setCollapse(_ collapse: Bool) {
        _collpase = collapse
    }
}

class TreeItem: TreeProtocol
{
    // TreeProtocol
    var _id: String
    var _name: String
    var _type: FileType
    var _collpase: Bool
    var _level: Int {
        get {
            if let parent = _parent {
                return parent._level + 1
            } else {
                return 0
            }
        }
    }
    var _childrenCount: Int {
        get {
            return _children.count
        }
    }
    var _hiddenModel: Bool
    
    //MARK: 要严格注意 _parent _children 不能自己引用自己
    var _parent: TreeItem? = nil //父层级
    var _children: [TreeItem]  = [] //子层级 如果 _type 为 .folder类型 才允许有children
    
    init(_id: String, _name: String, _type: FileType, _collpase: Bool,_hiddenModel: Bool = false) {
        self._id = _id
        self._name = _name
        self._type = _type
        self._collpase = _collpase
        self._hiddenModel  = _hiddenModel
    }
    
    func canAddChild() -> Bool {
        return _type == .folder
    }
    
    private func remove(_ id: String) {
        if let index = _children.firstIndex(where: {$0._id == id}) {
            _children.remove(at: index)
        }
    }
    
    private func removeAllChildRecursive() {
        for child in _children {
            child._parent = nil
            child.removeAllChildRecursive()
        }
    }
    
    func hasChild(_ id: String) -> Bool {
        let index = _children.firstIndex(where: {$0._id == id})
        return index != nil
    }
    
    @discardableResult
    func setChildren(_ newChildren: [TreeItem]) -> Bool {
        if !canAddChild() {
            print("\(#function),type is: \(_type),can't add children")
            return false
        }
        var needAdd: [TreeItem] = []
        for child in newChildren {
            if child._id != self._id {
                child._parent?.remove(child._id)
                child._parent = self
                needAdd.append(child)
            } else {
                print("\(#function),can't set self as children")
                return false
            }
        }
        _children = needAdd
        return true
    }
    
    //MARK:  删除自己
    func deleteSelf() {
        self._parent?.remove(_id)
        self._parent = nil
        
        for child in _children {
            child.deleteSelf()
        }
        _children = []
    }
    
    //MARK: 删除子节点
    func deleteChildren(_ Childrens: Set<String>) {
        var needDelete: [TreeItem] = []
        _children.enumerated().forEach{(_,value) in
            if Childrens.contains(value._id) {
                needDelete.append(value)
            }
        }
        if needDelete.count != 0 {
            for i in 0...needDelete.count-1 {
                remove(needDelete[i]._id)
                needDelete[i]._parent = nil
            }
        }
    }
    
    //MARK: 一个item插入到其父节点 或者 其父节点将其设置为子节点 两者取一
    @discardableResult
    func setParent(_ newParent: TreeItem?) -> Bool {
        // 判断该parent是否能设置子节点，以及待设置的是否和自己同id
        if let p = newParent {
            if !p.canAddChild() {
                print("\(#function),this parent can't set children")
                return false
            }
            if p._id == self._id {
                print("\(#function),can't set self as parent")
                return false
            }
        }
        
        self._parent?.remove(_id)
        self._parent = newParent
        newParent?._children.append(self)
        
        return true
    }
    
    // 插入的是唯一的child，已经存在的不给予插入
    @discardableResult
    func insertChild(_ child: TreeItem,at: Int) -> Bool {
        if !canAddChild() {
            print("\(#function),this type \(_type),can't add child")
            return false
        }
        
        
        if child._id != _id {
            if !hasChild(child._id) {
                child._parent?.remove(child._id)
                _children.insert(child, at: at)
                child._parent = self
                return true
            } else {
                return false
            }
        }
        return false
    }
    @discardableResult
    func insertChildAtLast(_ child: TreeItem) -> Bool {
        if !canAddChild() {
            print("\(#function),this type \(_type),can't add child")
            return false
        }
        if child._id != _id {
            if !hasChild(child._id) {
                child._parent?.remove(child._id)
                _children.append(child)
                child._parent = self
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func getTopID() -> String {
        return _parent?.getTopID() ?? _id
    }
    
    func getNeedShowItems(outItems: inout [TreeProtocol]) -> Void {
        outItems.append(self)
        if !_collpase {
            for child in _children {
                child.getNeedShowItems(outItems: &outItems)
            }
        }
    }
    
    // 迭代递归查找子节点，子子节点是否存在
    func getItemRecursive(id: String,target: inout TreeItem?,isFind: inout Bool) -> Void {
        if isFind { return }
        if self._id == id {
            target = self
            isFind = true
            return
        }
        for child in _children {
            if !isFind {
                child.getItemRecursive(id: id, target: &target, isFind: &isFind)
            }
        }
    }
    
    func getItemNoRecursive(id: String) -> TreeItem? {
        return _children.first(where: {$0._id == id})
    }
    
    
    //MARK: 用于子类更新他们自己额外的信息
    func updateAdditionalInfo(_ json: [String:Any]) {
        //在子类中实现具体
    }
    
    func getChildrenID(result: inout Set<String>) {
        _children.enumerated().forEach {(_,value) in
            result.insert(value._id)
        }
    }

//------------------ hidden start ---------------------
    
    //MARK: 父节点主动隐藏/显示了，其子节点全部隐藏/显示
    private func affectChildRecursiveWhenHidden(_ parentHidden: Bool) {
        for child in _children {
            child._hiddenModel = parentHidden
            child.affectChildRecursiveWhenHidden(parentHidden)
        }
    }
    //MARK: 子节点主动隐藏了，父节点根据其所有子节点是否隐藏来隐藏；显示了，父节点一定显示
    private func affectParentRecursiveWhenHidden(_ childHidden: Bool) {
        if let parent = _parent {
            // 两者一样的话啥也不用处理
            if parent._hiddenModel != childHidden {
                // 如果一个子节点主动隐藏了，就看其所有的子节点是否都隐藏，是的话，自己也得隐藏
                if childHidden {
                    var allChildrenHidden = true
                    for child in parent._children {
                        if child._hiddenModel != true {
                            allChildrenHidden = false
                            break
                        }
                    }
                    // 如果所有孩子都隐藏了，则自己也隐藏
                    if allChildrenHidden {
                        parent._hiddenModel = true
                        parent.affectParentRecursiveWhenHidden(true)
                    }
                } else {
                    parent._hiddenModel = false
                    parent.affectParentRecursiveWhenHidden(false)
                }
            }
        } else {
            print("\(_id): 不存在parent node")
        }
    }
    
    //MARK: 隐藏并隐藏其下的子节点子子节点
    func hiddenWithRecursive(_ hidden: Bool) {
        self._hiddenModel = hidden
        //printParentRecursive()
        affectChildRecursiveWhenHidden(hidden)
        affectParentRecursiveWhenHidden(hidden)
    }
//------------------ hidden end ---------------------
}
