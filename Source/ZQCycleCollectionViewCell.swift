//
//  ZQCycleCollectionViewCell.swift
//  ZQCycleScrollViewDemo
//
//  Created by Darren on 2019/8/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import Kingfisher

// MARK: 轮播视图cell
public class ZQCycleCollectionViewCell: UICollectionViewCell {
    
    fileprivate lazy var imageView:UIImageView = {
        let imageView:UIImageView = UIImageView()
        return imageView
    }()
    
    fileprivate lazy var titleLabel:UILabel = {
        let titleLabel:UILabel = UILabel()
        return titleLabel
    }()
    
    public var index:NSInteger?
    
    public var config:ZQCycleScrollConfig? {
        didSet {
            guard let config = config else { return }
            switch config.style {
            case .onlyImage:
                imageView.isHidden = false
                titleLabel.isHidden = true
                showImage()
                
            case .onlyText:
                imageView.isHidden = true
                titleLabel.isHidden = false
                showTitle()
                
            case .imageAndTitle:
                imageView.isHidden = false
                titleLabel.isHidden = false
                showImage()
                showTitle()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        if let config = config {
            let titleConfig = config.titleConfig
            titleLabel.frame = CGRect(x: 0, y: bounds.size.height - titleConfig.height, width: bounds.size.width, height: titleConfig.height)
        }
    }
}

// MARK: private
extension ZQCycleCollectionViewCell {
    fileprivate func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    
    fileprivate func showImage() {
        guard let config = config else { return }
        let imageConfig = config.imageConfig
        if let index = index {
            if let imgArr = imageConfig.imageArr, index < imgArr.count {
                let imgPath = imgArr[index]
                if imgPath.hasPrefix("http") {
                    imageView.kf.setImage(with: URL(string: imgPath), placeholder: imageConfig.placeholderImage)
                } else {
                    if let image = UIImage(named: imgPath) {
                        imageView.image = image
                    } else {
                        imageView.image = UIImage(contentsOfFile: imgPath)
                    }
                }
            }
        }
    }
    
    fileprivate func showTitle() {
        guard let config = config else { return }
        let titleConfig = config.titleConfig
        if let index = index {
            if let titleArr = titleConfig.titlesArr, index < titleArr.count {
                titleLabel.isHidden = false
                titleLabel.backgroundColor = titleConfig.backgroundColor
                titleLabel.font = titleConfig.font
                titleLabel.textColor = titleConfig.textColor
                titleLabel.textAlignment = titleConfig.textAlignment
                titleLabel.numberOfLines = titleConfig.numberOfLines
                titleLabel.text = titleArr[index]
            } else {
                titleLabel.isHidden = true
            }
        }
    }
}
