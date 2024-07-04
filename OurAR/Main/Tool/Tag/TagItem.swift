//
//  TagItem.swift
//  OurAR
//
//  Created by lee on 2023/7/27.
//

import Foundation


class TagItem : TreeItem
{
    var pakId: String = ""
    var parentId: String = ""
    var projectId: String = ""
    var location: String = ""
    var status: String = ""
    var color: String = ""
    var battachToFloor: String = ""
    var tagType: String = ""
    var banchorAlwaysDisplay: String = ""
    var createTime: String = ""
    
    
    override func updateAdditionalInfo(_ json: [String:Any]) {
        pakId = json["pakId"] as? String ?? ""
        parentId = json["parentId"] as? String ?? ""
        projectId = json["projectId"] as? String ?? ""
        location = json["location"] as? String ?? ""
        status = json["status"] as? String ?? ""
        color = json["color"] as? String ?? ""
        battachToFloor = json["battachToFloor"] as? String ?? ""
        tagType = json["type"] as? String ?? ""
        banchorAlwaysDisplay = json["banchorAlwaysDisplay"] as? String ?? ""
        createTime = json["createTime"] as? String ?? ""
    }
}
