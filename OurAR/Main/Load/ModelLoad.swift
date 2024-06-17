//
//  ModelLoad.swift
//  OurAR
//
//  Created by lee on 2023/6/2.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation
import UIKit
import CloudAR

//MARK: VJ场景加载的页面
class ModelLoadView: UIView {
    
    var loadImg: UIImageView!
    var loadLabel: UILabel!
    var loadProgress: UILabel! //未初始化
    var backBtn: BackBtnView! //退出按钮
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .white
        return activityIndicatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func initSubView()
    {
        loadImg = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        loadImg.image = UIImage(named: "loadbg")
        
        loadLabel = UILabel(frame: CGRect(x: bounds.width * 0.4, y: bounds.height * 0.55, width: bounds.width * 0.2, height: 30))
        loadLabel.font = UIFont.systemFont(ofSize: 18)
        loadLabel.text = "模型场景加载中"
        loadLabel.textColor = .black
        loadLabel.textAlignment = .center
        
        backBtn = BackBtnView(x: 0, y: 20, width: 40, height: 40)
        
        addSubview(loadImg)
        addSubview(loadLabel)
        addSubview(backBtn)
    }

    private func setupViews() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initSubView()
        //backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(activityIndicatorView)
        activityIndicatorView.center = center
        activityIndicatorView.startAnimating()
        
    }

    func show() {
        isHidden = false
    }

    func hide() {
        isHidden = true
    }
    
}
