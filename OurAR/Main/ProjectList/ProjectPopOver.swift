//
//  ProjectPopOver.swift
//  OurAR
//
//  Created by lee on 2023/8/7.
//

import Foundation
import UIKit

fileprivate let cell_left_right_pad: CGFloat = 15
fileprivate let popCellIdentifier: String = "popcell"

fileprivate enum PopCellType: UInt8
{
    case enter      = 0
    case edit       = 1
    case delete     = 2
}

fileprivate struct PopCellInfo
{
    var type: PopCellType!
    var iconName: String!
    var cellName: String!
    
    init(type: PopCellType!, iconName: String!, cellName: String!) {
        self.type = type
        self.iconName = iconName
        self.cellName = cellName
    }
}

fileprivate class ProjectPopCell: UITableViewCell
{
    var icon: UIImageView!
    var name: UILabel!
    var btn: UIButton!
    
    var cellInfo: PopCellInfo? = nil {
        didSet {
            if let new = cellInfo {
                icon.image = UIImage(named: new.iconName)
                name.text = new.cellName
                name.textColor = new.type == .delete ?
                    UIColor(red: 1, green: 38/255, blue: 38/255, alpha: 1) : UIColor(red: 34/255, green: 45/255, blue: 57/255, alpha: 1)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        let width: CGFloat = self.bounds.width
        let height: CGFloat = self.bounds.height
        let center_y: CGFloat = height / 2
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height * 0.8))
        btn.backgroundColor = UIColor(white: 1, alpha: 0)
        btn.center.y = center_y
        btn.addAction(UIAction(handler: {_ in
            //NOTICE:
            if let controller =  getControllerOfSubview(self) as? ProjectPopOverController {
                controller.handlePopEvent(type: self.cellInfo?.type)
            }
        }), for: .touchUpInside)
        contentView.addSubview(btn)
        
        let icon_start_x: CGFloat = cell_left_right_pad
        icon = UIImageView(frame: CGRect(x: icon_start_x, y: 0, width: 20, height: 20))
        icon.center.y = center_y
        icon.contentMode = .scaleAspectFill
        contentView.addSubview(icon)
        
        let name_start_x: CGFloat = icon_start_x + icon.bounds.width + 15
        name = UILabel(frame: CGRect(x: name_start_x, y: 0, width: width * 0.7, height: min(height,12)))
        name.center.y = center_y
        name.font = .systemFont(ofSize: min(height,12))
        contentView.addSubview(name)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ProjectPopOverView: UIView, UITableViewDataSource, UITableViewDelegate
{
    
    var popbg: UIImageView!
    var icon: UIImageView!
    var projectName: UILabel!
    var table: UITableView!
    
    private var popItems: [PopCellInfo] = [
        PopCellInfo(type: .enter, iconName: "enterproject", cellName: "进入AR模式"),
        PopCellInfo(type: .edit, iconName: "editproject", cellName: "编辑"),
        PopCellInfo(type: .delete, iconName: "deleteproject", cellName: "删除")]
    
    init(frame: CGRect,popPosition: CGPoint) {
        super.init(frame: frame)
        
        let pad_left_right: CGFloat = 10
        let headerHeight: CGFloat = 40
        let header_center_y: CGFloat = headerHeight / 2
        let icon_start_x: CGFloat = 20
        icon = UIImageView(frame: CGRect(x: icon_start_x, y: 0, width: 20, height: 20))
        icon.center.y = header_center_y
        icon.image = UIImage(named: "projecticon")
        addSubview(icon)
        
        let name_start_x: CGFloat = icon_start_x + icon.bounds.width + 8
        projectName = UILabel(frame: CGRect(x: name_start_x, y: 0, width: self.bounds.width - name_start_x - pad_left_right, height: 12))
        projectName.font = .systemFont(ofSize: 12)
        projectName.textColor = UIColor(red: 84/255, green: 96/255, blue: 109/255, alpha: 1)
        addSubview(projectName)
        
        let tableHeight: CGFloat = self.bounds.height - headerHeight - 15
        let tableWidth: CGFloat = self.bounds.width - pad_left_right * 2
        table = UITableView(frame: CGRect(x: pad_left_right, y: headerHeight, width: tableWidth, height: tableHeight))
        table.register(ProjectPopCell.self, forCellReuseIdentifier: popCellIdentifier)
        table.separatorStyle = .none
        addSubview(table)
        
        table.delegate = self
        table.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: popCellIdentifier, for: indexPath) as? ProjectPopCell {
            cell.cellInfo = popItems[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }
    
    //center 和 triangle都是相对屏幕的点
    func updatePosition(center: CGPoint,triangle: TrianglePoint,popOverPos: PopOverPosition) {
        self.center = center
    }
}


class ProjectPopOverController: UIViewController
{
    var projectPopView: ProjectPopOverView!
    private var triangleView: TriangleRectView!
    let popOverSize: CGSize = CGSize(width: 160, height: 190)
    
    var sourceView: UIView? = nil
    
    let pad: CGFloat = 10 //气泡距targetView Center的距离
    var triLen: CGFloat { //气泡直角三角形的斜边长度
        get {
            return 20
        }
    }
    var triangleOff: CGFloat { //实际的绘制的triangle rect view的长宽都要大一点
        get {
            return triLen / 2
        }
    }
    
    var popSize: CGSize {
        get {
            return CGSize(width: popOverSize.width + triangleOff * 2, height: popOverSize.height + triangleOff * 2)
        }
    }
    
    var projectInfo: [String:Any] = [:] {
        didSet {
            self.projectPopView?.projectName?.text = projectInfo["name"] as? String ?? ""
        }
    }
    
    var deleteAlert: UIAlertController?
    var modifyAlert: UIAlertController?
    
    init(targetView: UIView) {
        super.init(nibName: nil, bundle: nil)
        sourceView = targetView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0) // 整个大背景设为透明
        
        
        triangleView = TriangleRectView(frame: CGRect(x: 0, y: 0, width: popSize.width, height: popSize.height))
        triangleView.backgroundColor = UIColor(white: 0, alpha: 0)
        self.view.addSubview(triangleView)
        
        projectPopView = ProjectPopOverView(frame: CGRect(x: triangleOff, y: triangleOff, width: popOverSize.width, height: popOverSize.height), popPosition: CGPoint(x: 0, y: 0))
        self.view.addSubview(projectPopView)
        
        registerGesture()
        
        updatePopPosition()
    }
    
    private func registerGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !triangleView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    // 三角形位置相关的计算
    private func calculatePopOverPosition(viewCenter: CGPoint,screenSize: CGSize) -> (CGPoint,TrianglePoint,PopOverPosition,[CGPoint]) {
        //判断view的中心点处在屏幕的什么位置
        // 如果y方向 viewcenter.y靠近screen上下70%，这气泡在下和上
        // 如果x方向 viewcenter.x靠近screen左右70%，则气泡在右和左
        // 优先上和下
        
        //气泡弹窗相对viewCenter的位置
        var popOverPos: PopOverPosition = .left
        if viewCenter.x >= screenSize.width * 0.35 && viewCenter.x <= screenSize.width * 0.65 {
            if viewCenter.y < screenSize.height * 0.3 {
                popOverPos = .lower
            } else if viewCenter.y > screenSize.height * 0.7 {
                popOverPos = .upper
            } else {
                popOverPos = .left
            }
        } else if viewCenter.x > screenSize.width * 0.65 {
            if viewCenter.y < screenSize.height * 0.3 {
                popOverPos = .lowerLeft
            } else if viewCenter.y > screenSize.height * 0.7 {
                popOverPos = .upperLeft
            } else {
                popOverPos = .left
            }
        }
        
        //先初始化矩形四个点
        var points: [CGPoint] = [
            CGPoint(x: 0 + triangleOff , y: 0 + triangleOff),
            CGPoint(x: popSize.width - triangleOff, y: 0 + triangleOff),
            CGPoint(x: popSize.width - triangleOff, y: popSize.height - triangleOff),
            CGPoint(x: 0 + triangleOff, y: popSize.height - triangleOff)
        ]
        var popCenter: CGPoint = CGPoint(x: 0, y: 0)
        var triangle: TrianglePoint = TrianglePoint(
            p1: CGPoint(x: 0, y: 0),
            p2: CGPoint(x: 0, y: 0),
            p3: CGPoint(x: 0, y: 0))
        
        let ratio: CGFloat = 0.818 //不要黄金分割比
        switch popOverPos {
        case .left:
            popCenter = CGPoint(x: viewCenter.x - pad - popSize.width/2, y: viewCenter.y)
            triangle = TrianglePoint(
                p1: CGPoint(x: viewCenter.x - pad + triLen / 2, y: viewCenter.y),
                p2: CGPoint(x: viewCenter.x - pad, y: viewCenter.y - triLen / 2),
                p3: CGPoint(x: viewCenter.x - pad, y: viewCenter.y + triLen / 2))
            // 直角三角形直角点的相对位置
            let vertex: CGPoint = CGPoint(x: popSize.width, y: popSize.height / 2 + triLen / 2)
            points.insert(CGPoint(x: vertex.x - triLen / 2, y: vertex.y - triLen / 2), at: 2)
            points.insert(vertex,at: 3)
            points.insert(CGPoint(x: vertex.x - triLen / 2, y: vertex.y + triLen / 2), at: 4)
            break
        case .lower:
            popCenter = CGPoint(x: viewCenter.x, y: viewCenter.y + pad + popSize.height / 2)
            triangle = TrianglePoint(
                p1: CGPoint(x: viewCenter.x, y: viewCenter.y + pad - triLen / 2),
                p2: CGPoint(x: viewCenter.x - triLen / 2, y: viewCenter.y + pad),
                p3: CGPoint(x: viewCenter.x + triLen / 2, y: viewCenter.y + pad))
            
            let vertex: CGPoint = CGPoint(x: popSize.width / 2, y: 0)
            points.insert(CGPoint(x: vertex.x - triLen / 2, y: vertex.y + triLen / 2), at: 1)
            points.insert(vertex, at: 2)
            points.insert(CGPoint(x: vertex.x + triLen / 2, y: vertex.y + triLen / 2), at: 3)
            break
        case .upper:
            popCenter = CGPoint(x: viewCenter.x, y: viewCenter.y - pad - popSize.height / 2)
            triangle = TrianglePoint(
                p1: CGPoint(x: viewCenter.x, y: viewCenter.y - pad + triLen / 2),
                p2: CGPoint(x: viewCenter.x - triLen / 2, y: viewCenter.y - pad),
                p3: CGPoint(x: viewCenter.x + triLen / 2, y: viewCenter.y - pad))
            
            let vertex: CGPoint = CGPoint(x: popSize.width / 2, y: popSize.height)
            points.insert(CGPoint(x: vertex.x + triLen / 2, y: vertex.y - triLen / 2), at: 3)
            points.insert(vertex, at: 4)
            points.insert(CGPoint(x: vertex.x - triLen / 2, y: vertex.y - triLen / 2), at: 5)
        case .lowerLeft:
            //位于viewcenter的左下
            popCenter = CGPoint(x: viewCenter.x - popSize.width * (ratio - 0.5), y: viewCenter.y + pad + popSize.height / 2	)
            triangle = TrianglePoint(
                p1: CGPoint(x: viewCenter.x, y: viewCenter.y + pad - triLen / 2),
                p2: CGPoint(x: viewCenter.x - triLen / 2, y: viewCenter.y + pad),
                p3: CGPoint(x: viewCenter.x + triLen / 2, y: viewCenter.y + pad))
            
            let vertex = CGPoint(x: popSize.width * ratio, y: 0)
            points.insert(CGPoint(x: vertex.x - triLen / 2, y: vertex.y + triLen / 2), at: 1)
            points.insert(vertex, at: 2)
            points.insert(CGPoint(x: vertex.x + triLen / 2, y: vertex.y + triLen / 2), at: 3)
        case .upperLeft:
            popCenter = CGPoint(x: viewCenter.x - popSize.width * (ratio - 0.5), y: viewCenter.y - pad - popSize.height / 2)
            triangle = TrianglePoint(
                p1: CGPoint(x: viewCenter.x, y: viewCenter.y - pad + triLen / 2),
                p2: CGPoint(x: viewCenter.x - triLen / 2, y: viewCenter.y - pad),
                p3: CGPoint(x: viewCenter.x + triLen / 2, y: viewCenter.y - pad))
            
            let vertex = CGPoint(x: popSize.width * ratio, y: popSize.height)
            points.insert(CGPoint(x: vertex.x + triLen / 2, y: vertex.y - triLen / 2), at: 3)
            points.insert(vertex, at: 4)
            points.insert(CGPoint(x: vertex.x - triLen / 2, y: vertex.y - triLen / 2), at: 5)
        default:
            //这里只是没有考虑其他情况，本应该考虑，但没考虑（说了好像没说）
            break
        }
        
        return (popCenter,triangle,popOverPos,points)
    }
    
    //MARK: 根据targetview的中心点位置来重置气泡弹窗的位置
    private func updatePopPosition() {
        guard let targetView = sourceView else
        {
            print("update pop position failed, source view is nil")
            return
        }
        
        var superView: UIView? = targetView.superview
        var childView: UIView = targetView
        
        var point:CGPoint = CGPoint(x: targetView.bounds.origin.x + targetView.bounds.width / 2, y: targetView.bounds.origin.y + targetView.bounds.height / 2)
        while let superV = superView {
            point = childView.convert(point, to: superV)
            superView = superV.superview
            childView = superV
        }
        
        let viewCenterInWindow = point
        let screenSize = UIScreen.main.bounds.size
        
        let (Center,_,_,Points) = calculatePopOverPosition(viewCenter: viewCenterInWindow, screenSize: screenSize)
        
        self.projectPopView!.center = Center
        self.triangleView!.center = Center
        
        self.triangleView!.pathInfo = PopPathInfo(points: Points, absolute: false, clockwise: true, size:popSize, popOverIndex: 0)
    }
    
    fileprivate func handlePopEvent(type: PopCellType?) {
        if let eventType = type {
            switch eventType {
            case .delete:
                showDeleteAlert()
                break
            case .edit:
                showEditAlert()
                break
            case .enter:
                if let id = projectInfo["id"] as? String {
                    print(id)
                    let (isSuccess,reason) = enterBIMScreen(currViewController: self, needLoadProject: id, screenType: .AR)
                    if !isSuccess {
                        showTip(tip: reason, parentView: self.view, tipColor_bg_fail, tipColor_text_fail){}
                    }
                }
                break
            }
        }
    }
    
    private func showDeleteAlert() {
        deleteAlert = UIAlertController(title: "提示", message: "将删除名称为'\(projectInfo["name"] as? String ?? "")'的数据,是否继续?", preferredStyle: .alert)
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.deleteAlert = nil
        }
        deleteAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            if let id = self.projectInfo["id"] as? String {
                self.handleDeleteProject(id: id)
            }
        }
        deleteAlert?.addAction(okAction)
        
        present(deleteAlert!, animated: true)
        
    }
    private func showEditAlert() {
        modifyAlert = UIAlertController(title: "提示", message: "", preferredStyle: .alert)
        modifyAlert?.addTextField { textField in
            textField.placeholder = self.projectInfo["name"] as? String ?? ""
        }
        // 添加取消动作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.modifyAlert = nil
        }
        modifyAlert?.addAction(cancelAction)
        
        // 添加确定动作
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let inputText = self.modifyAlert?.textFields?.first?.text {
                self.handleModifyProject(name: inputText, id: self.projectInfo["id"] as? String ?? "")
            }
        }
        modifyAlert?.addAction(okAction)
        
        present(modifyAlert!, animated: true)
        
    }
    
    private func handleDeleteProject(id: String) {
        sendDeleteProject(projectID: "1", completion: { result in
            //不论删除成功或失败都dismiss
            //self.deleteAlert?.dismiss(animated: true)
            showTip(tip: result ? "删除成功" : "删除失败" , parentView: self.view, result ? tipColor_bg_success : tipColor_bg_fail, result ? tipColor_text_success : tipColor_text_fail, completion: {})
            
            if result {
                if let controller = self.presentingViewController as? ProjectController {
                    self.dismiss(animated: true)
                    controller.queryProjectList()
                }
            }
        })
    }
    private func handleModifyProject(name: String,id: String) {
        sendModifyProject(projectID: id, name: name){ result in
            showTip(tip: result ? "修改成功" : "修改失败" , parentView: self.view, result ? tipColor_bg_success : tipColor_bg_fail, result ? tipColor_text_success : tipColor_text_fail, completion: {})
            if result {
                if let controller = self.presentingViewController as? ProjectController {
                    self.dismiss(animated: true)
                    controller.queryProjectList()
                }
            }
        }
    }
}
