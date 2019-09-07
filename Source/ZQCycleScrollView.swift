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
    
    /// 滚动到某个索引
    ///
    /// - Parameters:
    ///   - cycleScrollView: 轮播视图
    ///   - index: 索引
    @objc optional func cycleScrollView(cycleScrollView:ZQCycleScrollView, didScrollToIndex index:Int)
    
    /// 选中某个索引
    ///
    /// - Parameters:
    ///   - cycleScrollView: 轮播视图
    ///   - index: 所以
    @objc optional func cycleScrollView(cycleScrollView:ZQCycleScrollView, didSelectItemAtIndex index:Int)
    
    /// 自定义cell的Class
    ///
    /// - Parameter cycleScrollView: 轮播视图
    /// - Returns: AnyClass
    @objc optional func customCollectionViewCellClassForCycleScrollView(cycleScrollView:ZQCycleScrollView) -> AnyClass
    
    /// 自定义cell的Nib
    ///
    /// - Parameter cycleScrollView: 轮播视图
    /// - Returns: UINib
    @objc optional func customCollectionViewCellNibForCycleScrollView(cycleScrollView:ZQCycleScrollView) -> UINib
    
    /// 自定义cell的个数
    ///
    /// - Parameter cycleScrollView: 轮播视图
    /// - Returns: Int
    @objc optional func customCollectionViewCellNumber(cycleScrollView:ZQCycleScrollView) -> Int
    
    /// 自定义cell的数据填充
    ///
    /// - Parameters:
    ///   - cycleScrollView: 轮播视图
    ///   - cell: 自定义cell
    ///   - index: 索引
    @objc optional func setupCustomTableViewCell(cycleScrollView:ZQCycleScrollView, cell:UITableViewCell, forIndex index:Int)
}

// MARK: 轮播视图
public class ZQCycleScrollView: UIView {
    
    public typealias cycleScrollViewClosure = (_ index:Int) -> ()
    
    /// 滚动监听
    public var didScrollOperationClosure:cycleScrollViewClosure?
    
    /// 点击监听
    public var didSelectOperationClosure:cycleScrollViewClosure?
    
    public weak var delegate:ZQCycleScrollViewDelegate? {
        didSet {
            if let delegate = delegate {
                if let cellClass = delegate.customCollectionViewCellClassForCycleScrollView?(cycleScrollView: self) {
                    collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
                }
                else if let cellNib = delegate.customCollectionViewCellNibForCycleScrollView?(cycleScrollView: self) {
                    collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
                }
                else {
                    collectionView.register(ZQCycleCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                }
            }
        }
    }
    
    private let reuseIdentifier:String = "ZQCycleScrollViewCell"
    
    private var config:ZQCycleScrollConfig?
    
    private lazy var layout:UICollectionViewFlowLayout = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = self.bounds.size
        return layout
    }()
    
    private lazy var collectionView:UICollectionView = {
        let collectionView:UICollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var pageControl:UIControl?
    
    private var timer:Timer?
    
    /// 原始数量
    private var originalCount:Int = 0
    
    /// 总数量 = originalCount * 2
    private var itemTotalCount:Int = 0
    
    /// 从父视图移除时,得销毁timer,不然self被timer强持有,无法释放,不会执行deinit方法
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            invalidateTimerIfNeed()
        }
    }
    
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
        initState()
        setupTimerIfNeed()
    }
}

// MARK: private
extension ZQCycleScrollView {
    private func setupViews() {
        setupCollectionView()
        setupPageControl()
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
    }
    
    private func setupPageControl() {
        guard let config = config, let arr = config.imageConfig.imageArr else { return }
        switch config.contentConfig.style {
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
    
    private func currentCollectionViewIndex() -> NSInteger {
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
    
    private func currentIndexOfPageControlWithCurrentCellIndex(index:NSInteger) -> NSInteger {
        guard let config = config, let arr = config.imageConfig.imageArr else { return 0 }
        return (index % arr.count)
    }
    
    private func initState() {
        if let _ = delegate?.customCollectionViewCellClassForCycleScrollView?(cycleScrollView: self), let customCellNumber = delegate?.customCollectionViewCellNumber?(cycleScrollView: self) {
            originalCount = customCellNumber
        }
        else if let _ = delegate?.customCollectionViewCellNibForCycleScrollView?(cycleScrollView: self),
            let customCellNumber = delegate?.customCollectionViewCellNumber?(cycleScrollView: self) {
            originalCount = customCellNumber
        }
        else {
            guard let config = config, let arr = config.imageConfig.imageArr else { return }
            originalCount = arr.count
        }
        
        /// 两倍数量才能实现无限轮播
        itemTotalCount = originalCount * 2
        collectionView.reloadData()
        
        /// 默认滚动到中间
        let indexPath:IndexPath = IndexPath(item: originalCount, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        didScrollToItem(item: originalCount)
    }
    
    private func setupTimerIfNeed() {
        guard let config = config, config.contentConfig.autoScroll else { return }
        invalidateTimerIfNeed()
        let contentConfig:ZQCycleScrollContentConfig = config.contentConfig
        let timer:Timer = Timer(timeInterval: TimeInterval(contentConfig.autoScrollTimeInterval), target: self, selector: #selector(actionForTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func invalidateTimerIfNeed() {
        guard let config = config, config.contentConfig.autoScroll else { return }
        timer?.invalidate()
        timer = nil
    }
    
    private func didScrollToItem(item:Int) {
        let index:Int = item % originalCount
        delegate?.cycleScrollView?(cycleScrollView: self, didScrollToIndex: index)
        didScrollOperationClosure?(index)
    }
    
    private func didSelectItem(item:Int) {
        let index:Int = item % originalCount
        delegate?.cycleScrollView?(cycleScrollView: self, didSelectItemAtIndex: index)
        didSelectOperationClosure?(index)
    }
}

// MARK: action
extension ZQCycleScrollView {
    @objc private func actionForTimer() {
        guard let indexPath = collectionView.indexPathsForVisibleItems.last, indexPath.item + 1 < itemTotalCount else { return }
        let nextPath:IndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
        collectionView.scrollToItem(at: nextPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension ZQCycleScrollView : UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemTotalCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ZQCycleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ZQCycleCollectionViewCell
        cell.index = indexPath.item % originalCount
        cell.config = config
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem(item: indexPath.item)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width:CGFloat = bounds.size.width
        guard let pageControl = pageControl, width > 0  else { return }
        let offsetX:CGFloat = scrollView.contentOffset.x
        var page:Int = Int(offsetX / width + 0.5)
        page = page % originalCount
        if pageControl.isKind(of: ZQCycleScrollPageControl.self) {
            (pageControl as! ZQCycleScrollPageControl).currentPage = page
        } else if pageControl.isKind(of: UIPageControl.self) {
            (pageControl as! UIPageControl).currentPage = page
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimerIfNeed()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setupTimerIfNeed()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(collectionView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let width:CGFloat = bounds.size.width
        guard width > 0 else { return }
        let offsetX:CGFloat = scrollView.contentOffset.x
        let page:Int = Int(offsetX / width)
        
        /// 第一页
        /// 右滑collectionView到第一组第一张，即第一cell时，设置scrollView的contentOffset显示第二组的第一张，继续右滑，实现了无限右滑
        if page == 0 {
            collectionView.contentOffset = CGPoint(x: offsetX + CGFloat(originalCount) * width, y: 0)
        }
            
            /// 最后一页
            /// 左滑collectionView到第二组最后一张，即最后一个cell时，设置scrollView的contentOffset显示第一组的最后一张，继续左滑，实现了无限左滑
        else if page == itemTotalCount - 1 {
            collectionView.contentOffset = CGPoint(x: offsetX - CGFloat(originalCount) * width, y: 0)
        }
        didScrollToItem(item: page)
    }
}

