//
//  ZQCycleScrollConfig.swift
//  ZQCycleScrollView
//
//  Created by Darren on 2019/5/21.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 滚动方向
public enum ZQCycleScrollDirection {
    
    /// 水平
    case horizontal
    
    /// 竖直
    case vertical
}

// MARK: 显示风格
public enum ZQCycleScrollStyle {
    
    /// 纯图片
    case onlyImage
    
    /// 纯文本
    case onlyText
    
    /// 图片 + 标题
    case imageAndTitle
}

// MARK: pageControl风格
public enum ZQCyclePageControlStyle {
    
    /// 系统经典
    case classic
    
    /// 动画效果
    case animated
}

// MARK: pageControl位置
public enum ZQCyclePageControlAliment {
    
    /// 中间
    case center
    
    /// 右边
    case right
    
    /// 左边
    case left
}

// MARK: 轮播视图图片配置对象
public class ZQCycleScrollImageConfig: NSObject {
    
    /// 图片
    public var imageArr:[String]?
    
    /// 自动滚动间隔时间, 默认 2s
    public var autoScrollTimeInterval:CGFloat = 2.0
    
    /// 是否无限循环, 默认 true
    public var infiniteLoop:Bool = true
    
    /// 是否自动滚动, 默认 true
    public var autoScroll:Bool = true
    
    /// 滚动方向，默认 水平
    public var scrollDirection:ZQCycleScrollDirection = .horizontal
    
    /// 图片填充模式, 默认 .scaleToFill
    public var contentMode:UIView.ContentMode = .scaleToFill
    
    /// 占位图
    public var placeholderImage:UIImage?
}

// MARK: 轮播视图标题配置对象
public class ZQCycleScrollTitleConfig: NSObject {
    
    /// 标题
    public var titlesArr:[String]?
    
    /// 标题颜色 默认 .white
    public var textColor:UIColor = .white
    
    /// 字体 默认 14
    public var font:UIFont = UIFont.systemFont(ofSize: 14)
    
    /// 背景颜色 默认 UIColor.black.withAlphaComponent(0.5)
    public var backgroundColor:UIColor = UIColor.black.withAlphaComponent(0.5)
    
    /// 高度, 默认 30
    public var height:CGFloat = 30
    
    /// 文字对齐方式 默认 .center
    public var textAlignment:NSTextAlignment = .center
    
    /// 行数 默认 1
    public var numberOfLines:Int = 1
}

// MARK: 轮播视图分页控件配置对象
public class ZQCycleScrollPageControlConfig: NSObject {
    
    /// 是否显示分页控件
    public var showPageControl:Bool = true
    
    /// 页数
    public var numberOfPages:NSInteger = 1
    
    /// 是否在只有一张图时隐藏pagecontrol, 默认 true
    public var hidesForSinglePage:Bool = true
    
    /// 风格, 默认 .animated
    public var style:ZQCyclePageControlStyle = .animated
    
    /// 位置, 默认 .center
    public var aliment:ZQCyclePageControlAliment = .center
    
    /// 分页控件距离轮播图的底部间距（在默认间距基础上）的偏移量
    public var bottomOffset:CGFloat = 0.0
    
    /// 分页控件距离轮播图的右/左(aliment = .left)边间距（在默认间距基础上）的偏移量,
    public var rightOffset:CGFloat = 0.0
    
    /// 小园标大小
    public var dotSize:CGSize = CGSize(width: 10, height: 10)
    
    /// 当前小圆标颜色, 默认 .red
    public var currentDotColor:UIColor = .red
    
    /// 其他小圆标颜色, 默认 .lightGray
    public var dotColor:UIColor = .lightGray
    
    /// 当前小圆标图片
    public var currentDotImage:UIImage?
    
    /// 其他小圆标图片
    public var dotImage:UIImage?
    
    /// 小图标之间的距离, 默认 8
    public var spacingBetweenDots:CGFloat = 8.0
}

// MARK: 轮播视图配置对象
public class ZQCycleScrollConfig: NSObject {
    
    /// 显示风格, 默认是纯图片
    public var style:ZQCycleScrollStyle = .onlyImage
    
    /// 图片配置对象
    public var imageConfig:ZQCycleScrollImageConfig = ZQCycleScrollImageConfig()
    
    /// 标题配置对象
    public var titleConfig:ZQCycleScrollTitleConfig = ZQCycleScrollTitleConfig()
    
    /// 分页控件配置对象
    public var pageControlConfig:ZQCycleScrollPageControlConfig = ZQCycleScrollPageControlConfig()
}
