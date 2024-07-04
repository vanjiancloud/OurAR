//
//  BaseView.swift
//  OurAR
//
//  Created by lee on 2023/7/5.
//

import Foundation
import UIKit

class BaseView: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.initSubView()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initSubView() {
        
    }
}
