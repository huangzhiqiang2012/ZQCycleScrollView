//
//  ZQCycleScrollViewController.swift
//  ZQCycleScrollViewDemo
//
//  Created by Darren on 2019/8/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCycleScrollView

class ZQCycleScrollViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let config:ZQCycleScrollConfig = ZQCycleScrollConfig()
        config.style = .imageAndTitle
        let imageConfig:ZQCycleScrollImageConfig = config.imageConfig
        imageConfig.imageArr = [
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1564736515235&di=d27805179f7be46d4bed1e380315e265&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201609%2F01%2F20160901214059_cPZ5f.jpeg",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1564736515897&di=dcbf5abee4126336580511a465ac22e0&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F10%2F20161010163331_t4RmC.jpeg"]
        let titleConfig:ZQCycleScrollTitleConfig = config.titleConfig
        titleConfig.titlesArr = ["哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"]
//        titleConfig.height = 60
//        titleConfig.backgroundColor = .red
//        titleConfig.textColor = .blue
//        titleConfig.numberOfLines = 0
//        titleConfig.font = UIFont.systemFont(ofSize: 13)
        let cycleScrollView:ZQCycleScrollView = ZQCycleScrollView(frame: CGRect(x: 0, y: 90, width: view.bounds.size.width, height: 300), config: config, delegate: self)
        cycleScrollView.backgroundColor = .blue
        view.addSubview(cycleScrollView)
    }
}

extension ZQCycleScrollViewController : ZQCycleScrollViewDelegate {
    
}
