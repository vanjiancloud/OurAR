//
//  OurManagerTool.swift
//  OurAR
//
//  Created by chao chao on 2024/6/18.
//

import Foundation
import UIKit

func getIsIphone() -> Bool {
    if UIDevice.current.userInterfaceIdiom == .phone {
        return true
    }else {
        return false
    }
}
