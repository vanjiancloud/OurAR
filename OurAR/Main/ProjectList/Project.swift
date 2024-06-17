//
//  Project.swift
//  OurAR
//
//  Created by lee on 2023/8/4.
//

import Foundation
import UIKit
import CloudAR

fileprivate class headerView: UIView
{
    //var bg: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let labelHeight: CGFloat = 20
        let label_start_y: CGFloat = self.bounds.height - 15 - labelHeight
        label = UILabel(frame: CGRect(x: 0, y: label_start_y, width: self.bounds.width * 0.5, height: 18))
        label.text = ""
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .black
        label.center.x = self.bounds.width / 2
        addSubview(label)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class profileView: UIView
{
    var bg: UIImageView!
    var profile: UIImageView!
    var userName: UILabel!
    var idInfo: UILabel!
    var loginOtherBtn: UIButton! //好像不需要
    var exitLoginBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        bg.image = UIImage(named: "profilebg")
        bg.contentMode = .scaleAspectFill
        bg.layer.mask = makeMask(4, bg.bounds, [.allCorners])
        addSubview(bg)
        
        let profile_start_y: CGFloat = 65
        let profileSize: CGFloat = 60
        let pad: CGFloat = 10
        let userName_start_y:CGFloat = profile_start_y + profileSize + pad
        let idInfo_start_y:CGFloat = userName_start_y + pad + 20
        
        profile = UIImageView(frame: CGRect(x: 0, y: profile_start_y, width: 60, height: 60))
        profile.center.x = self.bounds.width / 2
        profile.backgroundColor = .gray
        profile.layer.mask = makeMask(profileSize/2, profile.bounds, [.allCorners])
        addSubview(profile)
        
        userName = UILabel(frame: CGRect(x: 0, y: userName_start_y, width: self.bounds.width * 0.5, height: 20))
        userName.text = car_UserInfo.name
        userName.font = .systemFont(ofSize: 16)
        userName.textColor = .black
        userName.textAlignment = .center
        userName.center.x = self.bounds.width / 2
        addSubview(userName)
        
        idInfo = UILabel(frame: CGRect(x: 0, y: idInfo_start_y, width: self.bounds.width * 0.8, height: 20))
        idInfo.text = "个人账号 ID: \(car_UserInfo.userID)"
        idInfo.font = .systemFont(ofSize: 12)
        idInfo.textColor = .gray
        idInfo.contentMode = .center
        idInfo.numberOfLines = 2
        idInfo.center.x = self.bounds.width / 2
        addSubview(idInfo)
        
        let btnHeight:CGFloat = 35
        let loginOther_start_y:CGFloat = self.bounds.height * 0.9 - btnHeight * 2 - 20
        let exit_start_y:CGFloat = loginOther_start_y + btnHeight + 20
        
//        loginOtherBtn = UIButton(frame: CGRect(x: 0, y: loginOther_start_y, width: self.bounds.width * 0.8, height: btnHeight))
//        loginOtherBtn.layer.borderColor = VJConfirmColor.cgColor
//        loginOtherBtn.setTitle("切换账号", for: <#T##UIControl.State#>)
        
        exitLoginBtn = UIButton(frame: CGRect(x: 0, y: exit_start_y, width: self.bounds.width * 0.8, height: btnHeight))
        exitLoginBtn.center.x = self.bounds.width / 2
        exitLoginBtn.setTitle("退出登录", for: .normal)
        exitLoginBtn.titleLabel?.font = .systemFont(ofSize: 13)
        exitLoginBtn.titleLabel?.textColor = .white
        exitLoginBtn.backgroundColor = VJConfirmColor
        exitLoginBtn.layer.mask = makeMask(2, exitLoginBtn.bounds, [.allCorners])
        exitLoginBtn.addAction(UIAction(handler: {_ in
            if let controller = getControllerOfSubview(self) {
                controller.dismiss(animated: true)
            }
            
        }),for: .touchUpInside)
        addSubview(exitLoginBtn)
        
        
        DispatchQueue.global().async {
            if !car_UserInfo.imgUrl.isEmpty {
                let url = URL(string: car_UserInfo.imgUrl)
                do {
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.profile.image = image
                    }
                }catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate enum progressType: UInt8
{
    case node   = 0
    case memory = 1
}

fileprivate class progressItem: UIView
{
    var img: UIImageView!
    var name: UILabel!
    var use: UILabel!
    var total: UILabel!
    var progress: UIProgressView!
    
    init(frame: CGRect,type: progressType) {
        super.init(frame: frame)
        
        let topHeight:CGFloat = 20
        let downHeight:CGFloat = 15
        let pad: CGFloat = 5
        let top_center_y:CGFloat = self.bounds.height / 2 - topHeight / 2 - pad
        let down_center_y: CGFloat = self.bounds.height / 2 + downHeight / 2 + pad
        
        let imgName = type == .node ? "nodeprogress" : "memoryprogress"
        img = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        img.image = UIImage(named: imgName)
        img.contentMode = .scaleAspectFill
        img.center.y = top_center_y
        addSubview(img)
        
        name = UILabel(frame: CGRect(x: 20 + pad, y: 0, width: 16*5, height: 16))
        name.text = type == .node ? "已用节点:" : "已用存储:"
        name.textColor = .black
        name.center.y = top_center_y
        name.textAlignment = .left
        name.font = .systemFont(ofSize: 12)
        addSubview(name)
        
        let use_start_x: CGFloat = 20 + name.bounds.width
        use = UILabel(frame: CGRect(x: use_start_x, y: 0, width: 40, height: 16))
        use.center.y = top_center_y
        use.textAlignment = .right
        use.font = .systemFont(ofSize: 12)
        use.textColor = UIColor(red: 0, green: 172/255, blue: 253/255, alpha: 1)
        addSubview(use)
        
        total = UILabel(frame: CGRect(x: use_start_x + use.bounds.width, y: 0, width: self.bounds.width * 0.3, height: 16))
        total.center.y = top_center_y
        total.textAlignment = .left
        total.font = .systemFont(ofSize: 12)
        total.textColor = .black
        addSubview(total)
        
        progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 8))
        progress.center.y = down_center_y
        progress.progress = 0
        progress.progressTintColor = VJBackgroundColor
        addSubview(progress)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class progressView: UIView
{
    var node: progressItem!
    var memory: progressItem!
    
    init(frame: CGRect,left_right_pad: CGFloat) {
        super.init(frame: frame)
        
        let pad: CGFloat = left_right_pad
        let progressWidth: CGFloat =  self.bounds.width / 2 - pad * 2
        let progressHeight: CGFloat = self.bounds.height
        node = progressItem(frame: CGRect(x: 20, y: 0,width: progressWidth , height: progressHeight), type: .node)
        node.center.y = self.bounds.height / 2
        memory = progressItem(frame: CGRect(x: progressWidth + pad * 2, y: 0, width: progressWidth, height: progressHeight), type: .memory)
        memory.center.y = self.bounds.height / 2
        addSubview(node)
        addSubview(memory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfo(data: [String:Any]) {
        if let currBF = data["currentCountBF"] as? String,
            let countBF = data["countBF"] as? String,
            let currSpace = data["currentCountSpace"] as? String,
            let countSpace = data["countSpace"] as? String
        {
            let currBF_f = Float(currBF) ?? 0.0
            let countBF_f = Float(countBF) ?? 1.0
            let currSpace_f = Float(currSpace) ?? 0.0
            let countSpace_f = Float(countSpace) ?? 1.0
            
            node?.use?.text = currBF
            node?.total?.text = "/\(countBF)"
            node?.progress?.setProgress(currBF_f/countBF_f, animated: true)
            
            memory?.use?.text = "\(currSpace)G"
            memory?.total?.text = "/\(countSpace)G"
            memory?.progress?.setProgress(currSpace_f/countSpace_f, animated: true)
        }
    }
}

fileprivate class projectHeader: UIView
{
    var title: UILabel!
    var totalInfo: UILabel!
    
    init(frame: CGRect,left_right_pad: CGFloat) {
        super.init(frame: frame)
        
        title = UILabel(frame: CGRect(x: left_right_pad, y: 0, width: self.bounds.width * 0.3, height: self.bounds.height))
        title.center.y = self.bounds.height / 2
        title.text = "项目列表"
        title.textColor = .white
        title.font = .systemFont(ofSize: 16)
        addSubview(title)
        
        totalInfo = UILabel(frame: CGRect(x: self.bounds.width * 0.6 - left_right_pad, y: 0, width: self.bounds.width * 0.4, height: 12))
        totalInfo.center.y = self.bounds.height / 2
        totalInfo.textColor = .white
        totalInfo.textAlignment = .right
        totalInfo.font = .systemFont(ofSize: 12)
        addSubview(totalInfo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class projectItem: UIView
{
    var icon: UIImageView!
    var nameLabel: UILabel!
    var createTimeLabel: UILabel!
    
    var btnItem: UIButton!  //监听点击进入场景的btn
    var btnModify: UIButton! //监听点击进行修改的btn
    
    var id: String = ""
    
    init(frame: CGRect,left_right_pad: CGFloat) {
        super.init(frame: frame)
        
        let width = bounds.width
        let height = bounds.height
        
        // icon size height * 0.6 pad_left = 10
        icon = UIImageView(frame: CGRect(x: left_right_pad, y: height * 0.2, width: height * 0.6, height: height * 0.6))
        icon.contentMode = .scaleToFill
        icon.layer.masksToBounds = true
        icon.layer.cornerRadius = height * 0.25
        icon.image = UIImage(named: "projecticon")
        
        nameLabel = UILabel(frame: CGRect(x: left_right_pad + height * 0.6 + 20, y: height * 0.25, width: width * 0.6, height: 16))
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = VJTextColor_07
        nameLabel.textAlignment = .left
        
        createTimeLabel = UILabel(frame: CGRect(x: left_right_pad + height * 0.6 + 20, y: height * 0.6, width: width * 0.6, height: 16))
        createTimeLabel.font = UIFont.systemFont(ofSize: 12)
        createTimeLabel.textColor = VJTextColor_07
        createTimeLabel.textAlignment = .left
        
        btnItem = UIButton(frame: CGRect(x: height * 0.1, y: height * 0.1, width: width - height * 0.1, height: height * 0.8))
        btnItem.backgroundColor = UIColor(white: 1, alpha: 0)
        btnItem.isUserInteractionEnabled = true
        btnItem.addTarget(self, action: #selector(pressItem), for: .touchDown)
        //btnItem.addTarget(self, action: #selector(itemTouchUpInside), for: .touchUpInside)
        //btnItem.backgroundColor = .black
        
        btnModify = UIButton(frame: CGRect(x: min(width - height * 0.1 - height * 0.5,width * 0.8), y:height * 0.1, width: height * 0.8, height: height * 0.8))
        btnModify.backgroundColor = UIColor(white: 1, alpha: 0)
        btnModify.isUserInteractionEnabled = true
        btnModify.setTitle("•••", for: .normal)
        btnModify.setTitleColor(UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.5), for: .normal)
        btnModify.addTarget(self, action: #selector(pressModify), for: .touchDown)
        
        addSubview(icon)
        addSubview(nameLabel)
        addSubview(createTimeLabel)
        addSubview(btnItem)
        addSubview(btnModify)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfo(_ projectItem: ProjectItem?)
    {
        if let project = projectItem
        {
            nameLabel.text = project.name
            createTimeLabel.text = project.createTime
            id = project.id ?? ""
        }
    }
    
    @objc func pressItem(sender: UIButton){
        // 开启一个场景
        print("press item")
        if let viewController = getControllerOfSubview(self) as? ProjectController
        {
            //startQueryModel(projectID: id, currViewController: viewController)
            let (isSuccess,reason) = enterBIMScreen(currViewController: viewController,needLoadProject: id,screenType: .AR) //默认以ar模式启动
            if !isSuccess {
                showTip(tip: reason, parentView: viewController.view, tipColor_bg_fail, tipColor_text_fail, completion: {})
            }
        }
    }
    @objc func pressModify(sender: UIButton){
        print("press modify")
        // 打开修改页面
        if let controller = getControllerOfSubview(self) as? ProjectController {
            controller.showPopView(targetView: self.btnModify!,info: ["name":self.nameLabel?.text ?? "","id":self.id])
        }
    }
}

fileprivate class projectListView: UIView
{
    var header: projectHeader!
    
    private var allProjectItem: [Int:projectItem] = [:]
    
    var column: Int = 2 //每行多少栏
    
    // 记录第一个projectitem的y应该在哪里
    var projectItem_start_y:CGFloat = 0
    // project item的统一高度
    let projectItem_height: CGFloat = 70
    
    var pad_left: CGFloat = 0
    var subview_width: CGFloat = 0
    
    init(frame: CGRect,left_right_pad: CGFloat) {
        super.init(frame: frame)
        
        projectItem_start_y = 65
        pad_left = left_right_pad
        
        subview_width = self.bounds.width / CGFloat(column) //每一个project item的长度
        
        header = projectHeader(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: projectItem_start_y), left_right_pad: pad_left)
        header.backgroundColor = VJBackgroundColor
        header.layer.mask = makeMask(8, header.bounds, [.topLeft,.topRight])
        addSubview(header)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addAllItemView(_ allProject: inout [Int:ProjectItem])
    {
        header?.totalInfo.text = "共有\(allProject.count)个项目"
        if allProject.count == 0 {
            return
        }
        for i in 0...allProject.count-1 {
            let x: CGFloat = CGFloat(i % column) * self.bounds.width / CGFloat(column)
            let y: CGFloat = projectItem_start_y + CGFloat(floor(CGFloat(i / column))) * projectItem_height
            let item = projectItem(frame: CGRect(x: x, y: y, width: subview_width, height: projectItem_height), left_right_pad: pad_left)
            item.updateInfo(allProject[i])
            addSubview(item)
            allProjectItem[i] = item
        }
    }
    
    private func removeAllItemView()
    {
        let keys = allProjectItem.keys
        for key in keys{
            let projectItemView = allProjectItem.removeValue(forKey: key)
            projectItemView?.removeFromSuperview()
        }
        header?.totalInfo?.text = "共有0个项目"
        
    }
    
    func updateProjectItemView(_ allProject: inout [Int: ProjectItem])
    {
        //删除现有的projectItemView
        removeAllItemView()
        
        //根据最新的project重新绘制
        addAllItemView(&allProject)
        
        //增加了子视图后，需要更新frame
        updateFrame()
        
    }
    
    func viewHeightContainsSubview() -> CGFloat
    {
        return max(bounds.height, projectItem_start_y + CGFloat(ceil(Double(allProjectItem.count) / Double(column))) * projectItem_height)
    }
    
    func updateFrame()
    {
        var newFrame = self.frame
        newFrame.size.height = viewHeightContainsSubview()
        self.frame = newFrame
        setNeedsLayout()
        layoutIfNeeded()
    }
}

class Project: UIView
{
    private var header: headerView!
    private var profile: profileView!
    private var progress: progressView!
    private var project: projectListView!
    
    var scrollView: UIScrollView!
    
    let gap: CGFloat = 15
    let left_right_pad: CGFloat = 25
    let headerHeight: CGFloat = 55
    var profileHeight: CGFloat = 0
    var profileWidth: CGFloat = 0
    var progressHeight: CGFloat = 50
    var progressWidth: CGFloat = 0
    var projectHeight: CGFloat = 0
    var projectWidth: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        profileHeight = self.bounds.height - headerHeight - gap * 2
        profileWidth = self.bounds.width * 0.28
        progressHeight = 65
        progressWidth = self.bounds.width - profileWidth - gap * 3
        projectWidth = progressWidth
        projectHeight = self.bounds.height - headerHeight - progressHeight - gap * 3
        
        // 头部
        header = headerView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: headerHeight))
        header.backgroundColor = .white
        addSubview(header)
        // 用户信息
        profile = profileView(frame: CGRect(x: gap, y: headerHeight + gap, width: profileWidth, height: profileHeight))
        //profile.backgroundColor = .black
        addSubview(profile)
        // 滑动
        let scrollHeight: CGFloat = self.bounds.height - headerHeight
        scrollView = UIScrollView(frame: CGRect(x: profileWidth + gap * 2, y: headerHeight, width: max(progressWidth,projectWidth), height: scrollHeight))
        scrollView.isUserInteractionEnabled = true
        scrollView.contentSize = CGSize(width: max(progressWidth,projectWidth), height: scrollHeight)
        
        // 滑动中的progress
        progress = progressView(frame: CGRect(x: 0, y: gap, width: progressWidth, height: progressHeight), left_right_pad: left_right_pad)
        progress.backgroundColor = .white
        scrollView.addSubview(progress)
        // 滑动中的project
        project = projectListView(frame: CGRect(x: 0, y: progressHeight + gap * 2, width: projectWidth, height: projectHeight),left_right_pad: left_right_pad)
        project.backgroundColor = .white
        scrollView.addSubview(project)
        
        addSubview(scrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProjectItems(_ allProject: inout [Int: ProjectItem]) {
        self.project!.updateProjectItemView(&allProject)
        
        updateScrollHeight()
    }
    
    private func updateScrollHeight() {
        let height = progressHeight + gap * 3 + project!.viewHeightContainsSubview()
        self.scrollView?.contentSize = CGSize(width: self.scrollView!.bounds.width, height: height)
        self.scrollView?.setNeedsLayout()
        self.scrollView?.layoutIfNeeded()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func updateProgressInfo(data: [String:Any]) {
        self.progress?.updateInfo(data: data)
    }
}

