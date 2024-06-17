//
//  ProjectController.swift
//  OurAR
//
//  Created by lee on 2023/8/7.
//

import Foundation
import UIKit

class ProjectController: UIViewController
{
    var allProject: [Int:ProjectItem] = [:]
    var project: Project!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        project = Project(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        project.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 249/255, alpha: 1)
        self.view = project
        
        queryProjectList()
        queryCount()
    }
    
    func queryProjectList() {
        print("queryProjectList")
        queryApplicationList { result in
            switch result{
            case.success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON )
                    if let JSON = JSONObject as? [String:Any] {
                        if let respCode = JSON["code"] as? Int,
                            let data = JSON["data"] as? [String:Any]
                        {
                            if respCode == 0
                            {
                                let itemList = data["list"] as? [[String:Any]]
                                
                                self.allProject.removeAll()
                              
                                //TODO 记录最新的项目list
                                var i = 0
                                itemList?.forEach{
                                    (item) in
                                   
                                    var projectItem = ProjectItem()
                                    projectItem.name = item["appName"] as? String
                                    projectItem.id = item["appid"] as? String
                                    projectItem.createTime = item["createTime"] as? String
                                    projectItem.size = item["fileSize"] as? String
                                    projectItem.status = item["applidStatus"] as? String
                                   
                                    self.allProject[i] = projectItem
                                    i += 1
                                   
                                }
                                //更新页面
                                DispatchQueue.main.async {
                                    self.project?.updateProjectItems(&self.allProject)
                                }                                
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
                print("error")
            }
        }
    }
    
    func queryCount() {
        queryCountInfo(){ result in
            switch result {
            case .success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON, options: .allowFragments)
                    if let JSON = JSONObject as? [String:Any] {
                        if let respCode = JSON["code"] as? Int,
                            let data = JSON["data"] as? [String:Any]
                        {
                            if respCode == 0
                            {
                                print("query count success")
                                // 更新progress view
                                DispatchQueue.main.async {
                                    self.project?.updateProgressInfo(data: data)
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
    
    func showPopView(targetView: UIView,info: [String:Any]) {
        let projectPopOverController = ProjectPopOverController(targetView: targetView)
        projectPopOverController.modalPresentationStyle = .overFullScreen
        projectPopOverController.projectInfo = info
        present(projectPopOverController, animated: true, completion: nil)
    }

}
