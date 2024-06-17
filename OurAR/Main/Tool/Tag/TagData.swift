//
//  TagData.swift
//  OurAR
//
//  Created by lee on 2023/7/27.
//

import Foundation
import UIKit

enum TagAlertActionType: UInt8
{
    case cancel         = 0
    case confirm        = 1
}

protocol TagDeleteActionProtocol
{
    func handleTagDeleteViewAction(type: TagAlertActionType,id: String)
}

protocol TagModifyActionProtocol
{
    func handleTagModifyViewAction(type: TagAlertActionType,params: [String:Any])
}
