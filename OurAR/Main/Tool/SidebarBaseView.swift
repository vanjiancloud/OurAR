//
//  SidebarBaseView.swift
//  OurAR
//
//  Created by lee on 2023/7/23.
//

import Foundation
import UIKit

//MARK: main tool 侧边栏的base view
class MTSidebarView : UIView, UIGestureRecognizerDelegate
{
    var closeBtn: CloseButtn! //关闭按钮
    var title: UILabel!
    
    //头部 title和closebtn的信息
    let headerHeight: CGFloat = 60 //整个头部的height
    let titleHeight: CGFloat = 30.0
    let closeBtnSize: CGFloat = 15.0
    let left_right_offset: CGFloat = 15
    let fontSize: CGFloat = 18
    
    init(frame: CGRect,titleName: String) {
        super.init(frame: frame)
        backgroundColor = VJViewBGColor //特定背景色要求  
        let title_btn_center_y = headerHeight / 2
        // 设置视图的遮罩层
        //self.layer.mask = makeMask(8,self.bounds,[.topLeft,.bottomLeft])
        
        // title
        title = UILabel(frame: CGRect(x: left_right_offset, y: 0, width: bounds.width * 0.4, height: titleHeight))
        title.text = titleName
        title.textColor = .white
        title.textAlignment = .left
        title.font = .boldSystemFont(ofSize: fontSize)
        title.center.y = title_btn_center_y
        addSubview(title)
        // closeBtn
        closeBtn = CloseButtn(frame: CGRect(x: bounds.width - left_right_offset - closeBtnSize, y: 0, width: closeBtnSize, height: closeBtnSize))
        closeBtn.center.y = title_btn_center_y
//        closeBtn.addAction(UIAction(handler: { _ in
//            //
//            self.handleClose()
//        }), for: .touchUpInside)
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(myButtonTap(_:)))
        btnTap.cancelsTouchesInView = true
        btnTap.delegate = self
        closeBtn.addGestureRecognizer(btnTap)
        addSubview(closeBtn)
        
        initSubView()
    }
    
    @objc func myButtonTap(_ sender: UITapGestureRecognizer) {
        self.handleClose()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initSubView() {}
    func handleClose() {}
}
