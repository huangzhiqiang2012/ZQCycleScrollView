//
//  ZQCycleScrollPageControl.swift
//  ZQCycleScrollViewDemo
//
//  Created by Darren on 2019/8/5.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 分页控制器
public class ZQCycleScrollPageControl: UIControl {
    
    private var config:ZQCycleScrollPageControlConfig?
    
    public var currentPage:NSInteger? {
        didSet {
            if let currentPage = currentPage {
                
            }
        }
    }
}

// MARK: public
public extension ZQCycleScrollPageControl {
    convenience init(config:ZQCycleScrollPageControlConfig?) {
        self.init()
        self.config = config
    }
}
