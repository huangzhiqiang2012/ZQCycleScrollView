//
//  ZQCycleScrollView.swift
//  ZQCycleScrollView
//
//  Created by Darren on 2019/5/21.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 代理
@objc public protocol ZQCycleScrollViewDelegate : NSObjectProtocol {

}

// MARK: 轮播视图
public class ZQCycleScrollView: UIView {
    fileprivate let reuseIdentifier:String = "ZQCycleScrollViewCell"
    
    fileprivate var config:ZQCycleScrollConfig?
    
    fileprivate weak var delegate:ZQCycleScrollViewDelegate?
    
    fileprivate lazy var layout:UICollectionViewFlowLayout = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = self.bounds.size
        return layout
    }()
    
    fileprivate lazy var collectionView:UICollectionView = {
        let collectionView:UICollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ZQCycleCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    fileprivate var pageControl:UIControl?
    
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
}

// MARK: public
public extension ZQCycleScrollView {
    convenience init(frame:CGRect, config:ZQCycleScrollConfig, delegate:ZQCycleScrollViewDelegate) {
        self.init(frame:frame)
        self.config = config
        self.delegate = delegate
        setupViews()
    }
}

// MARK: private
extension ZQCycleScrollView {
    fileprivate func setupViews() {
        setupCollectionView()
        setupPageControl()
    }
    
    fileprivate func setupCollectionView() {
        addSubview(collectionView)

    }
    
    fileprivate func setupPageControl() {
        guard let config = config, let arr = config.imageConfig.imageArr else { return }
        switch config.style {
        case .onlyText:
            return
            
        case .onlyImage, .imageAndTitle:
            if arr.count < 1 { return }
        }
        if arr.count == 1 && config.pageControlConfig.hidesForSinglePage { return }
        let pageControlConfig:ZQCycleScrollPageControlConfig = config.pageControlConfig
        switch pageControlConfig.style {
        case .classic:
            let pageControl:UIPageControl = UIPageControl()
            pageControl.numberOfPages = arr.count
            pageControl.currentPageIndicatorTintColor = pageControlConfig.currentDotColor
            pageControl.pageIndicatorTintColor = pageControlConfig.dotColor
            pageControl.currentPage = currentIndexOfPageControlWithCurrentCellIndex(index: currentCollectionViewIndex())
            pageControl.isUserInteractionEnabled = false
            addSubview(pageControl)
            self.pageControl = pageControl
            
        case .animated:
            pageControlConfig.numberOfPages = arr.count
            let pageControl:ZQCycleScrollPageControl = ZQCycleScrollPageControl(config: pageControlConfig)
            pageControl.currentPage = currentIndexOfPageControlWithCurrentCellIndex(index: currentCollectionViewIndex())
            pageControl.isUserInteractionEnabled = false
            addSubview(pageControl)
            self.pageControl = pageControl
        }
    }
    
    fileprivate func currentCollectionViewIndex() -> NSInteger {
        if collectionView.bounds.size.width == 0 || collectionView.bounds.size.height == 0 { return 0 }
        var index:NSInteger = 0
        switch layout.scrollDirection {
        case .horizontal:
            index = NSInteger((collectionView.contentOffset.x + layout.itemSize.width * 0.5) / layout.itemSize.width)
            
        case .vertical:
            index = NSInteger((collectionView.contentOffset.x + layout.itemSize.width * 0.5) / layout.itemSize.width)
            
        default:
            break
        }
        return max(0, index)
    }
    
    fileprivate func currentIndexOfPageControlWithCurrentCellIndex(index:NSInteger) -> NSInteger {
        guard let config = config, let arr = config.imageConfig.imageArr else { return 0 }
        return (index % arr.count)
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension ZQCycleScrollView : UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let config = config, let arr = config.imageConfig.imageArr else { return 0 }
        return arr.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ZQCycleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ZQCycleCollectionViewCell
        cell.index = indexPath.item
        cell.config = config
        return cell
    }
}

