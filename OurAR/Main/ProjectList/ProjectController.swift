//
//  ProjectController.swift
//  OurAR
//
//  Created by lee on 2023/8/7.
//

import Foundation
import UIKit

class ProjectController: UIViewController, UIScrollViewDelegate {
    var allProject: [Int:ProjectItem] = [:]
    var project: Project!
    var currentPage = 1
    var isLoadingMore = false  // 防止重复加载
    var hasMoreData = true  // 是否还有更多数据
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        project = Project(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        project.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 249/255, alpha: 1)
        self.view = project
        project.onRefresh = { [weak self] in
            guard let self = self else { return }
            currentPage = 1
            hasMoreData = true
            self.queryProjectList(page: currentPage)
            self.queryCount()
        }
        project.scrollView.delegate = self
                
        queryProjectList(page: currentPage)
        queryCount()
    }
    
    func removeProject(id: String) {
        if let keyToRemove = self.allProject.first(where: { $0.value.id == id })?.key {
            let previousCount = self.allProject.count
            self.allProject.removeValue(forKey: keyToRemove)
            
            var tempDict = [Int: ProjectItem]()
            for (newIndex, (_, value)) in self.allProject.sorted(by: { $0.key < $1.key }).enumerated() {
                var updatedItem = value
                updatedItem.projectCount = "\(previousCount - 1)"
                tempDict[newIndex] = updatedItem
            }
            self.allProject = tempDict
            
            if let firstKey = self.allProject.keys.first {
                var firstItem = self.allProject[firstKey]
                firstItem?.projectCount = "\(self.allProject.count)"
                self.allProject[firstKey] = firstItem
            }
        }
        
        DispatchQueue.main.async {
            self.project?.updateProjectItems(&self.allProject)
        }
    }

    func queryProjectList(page: Int) {
        print("queryProjectList page: \(page)")
        
        guard hasMoreData else {
            print("没有更多数据")
            self.project.endRefreshing()
            return
        }

        queryApplicationList(page: page) { result in
            DispatchQueue.main.async {
                self.project.endRefreshing()
            }
            self.isLoadingMore = false
            
            switch result {
            case .success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON)
                    if let JSON = JSONObject as? [String: Any],
                       let respCode = JSON["code"] as? Int,
                       let data = JSON["data"] as? [String: Any],
                       respCode == 0
                    {
                        let itemList = data["list"] as? [[String: Any]] ?? []
                        let isLastPage = (data["isLastPage"] as? Int) == 1
                        
                        // 记录总项目数（放入第一个 item 里）
                        let totalCountString: String? = {
                            if let totalInt = data["total"] as? Int {
                                return String(totalInt)
                            } else if let totalStr = data["total"] as? String {
                                return totalStr
                            }
                            return nil
                        }()
                        
                        if self.currentPage == 1 {
                            self.allProject .removeAll()
                        }

                        // 记录当前已有数量，用作下标
                        var currentIndex = self.allProject.count
                        
                        for item in itemList {
                            var projectItem = ProjectItem()
                            projectItem.name = item["appName"] as? String
                            projectItem.id = item["appid"] as? String
                            projectItem.createTime = item["createTime"] as? String
                            projectItem.size = item["fileSize"] as? String
                            projectItem.status = item["applidStatus"] as? String
                            projectItem.currVersion = item["currVersion"] as? String
                            if let progress = item["progress"] as? Int {
                                projectItem.progress = String(progress)
                            } else if let progress = item["progress"] as? String {
                                projectItem.progress = progress
                            } else {
                                projectItem.progress = nil // 或者默认值
                            }
                            projectItem.applidStatus = item["applidStatus"] as? String
                            projectItem.projectCount = totalCountString

                            self.allProject[currentIndex] = projectItem
                            currentIndex += 1
                        }

                        // 更新页面
                        DispatchQueue.main.async {
                            self.project?.updateProjectItems(&self.allProject)
                        }

                        self.hasMoreData = !isLastPage
                        if !isLastPage {
                            self.currentPage += 1
                        }
                    }
                }
            case .failure(let error):
                print("queryProjectList error: \(error)")
            }
        }
    }

    
    // UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // 判断是否快到底部，阈值为100，可根据需求调整
        if offsetY > contentHeight - scrollViewHeight - 100 {
            // 触发加载下一页
            if !isLoadingMore && hasMoreData {
                isLoadingMore = true
                queryProjectList(page: currentPage)
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
