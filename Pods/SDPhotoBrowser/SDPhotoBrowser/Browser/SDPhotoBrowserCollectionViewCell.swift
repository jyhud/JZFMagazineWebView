//
//  SDPhotoBrowserCollectionViewCell.swift
//  lolbox
//
//  Created by Sunny on 2017/3/2.
//  Copyright © 2017年 duowan. All rights reserved.
//

import UIKit
import Kingfisher

class SDPhotoBrowserCollectionViewCell: UICollectionViewCell {
    
    var singleTapImageClosure: ((Int) -> Void)?
    
    fileprivate var indexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    fileprivate lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.contentView.frame.width - kSDPhotoBrowserMargin, height: self.contentView.frame.height))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        scrollView.backgroundColor = UIColor.black
        scrollView.delegate = self
        return scrollView
    }()
    
    
    fileprivate lazy var imageView: AnimatedImageView = {[unowned self] in
        
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.black
        return imageView
    }()

    
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = { [unowned self] in
    
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicatorView.center = self.center
        return activityIndicatorView
    }()
    
    var photoUrl: URL? {
    
        didSet {
        
            guard let photoUrl = photoUrl else { return }
            
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            
            imageView.kf.setImage(with: photoUrl, placeholder: nil, options: nil, progressBlock: nil) { [unowned self] (resultImage, error, cacheType, imageUrl) in
                
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                if error == nil {
                    self.setupImageViewFrame()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        addGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupScrollView()
        addGestures()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.contentView.frame.width - kSDPhotoBrowserMargin, height: self.contentView.frame.height)
        activityIndicatorView.center = self.center
        setupImageViewFrame()
    }

}

// MARK:- Private Methods
fileprivate extension SDPhotoBrowserCollectionViewCell {
    
    func addGestures() {
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
    
        singleTap.require(toFail: doubleTap)
        
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
    }
    
    func setupScrollView() {
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(activityIndicatorView)
    }
}

// MARK:- Public Methods
extension SDPhotoBrowserCollectionViewCell {
    
    /// 外界调用这个方法来重置cell
    func resetZoomSacle() {
    
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
}

// MARK:- SDPhotoBrowserCellConfigProtocol
extension SDPhotoBrowserCollectionViewCell: SDPhotoBrowserCellConfigProtocol {

    func sd_config(of url: URL?, withIndexPath indexPath: IndexPath) {
        
        self.resetUI()
        self.indexPath = indexPath
        self.photoUrl = url
    }
}

// MARK:- Action
fileprivate extension SDPhotoBrowserCollectionViewCell {
    
    @objc func handleSingleTap(_ tapGesture: UITapGestureRecognizer) {
        
        singleTapImageClosure?(indexPath.item)
    }

    // 双击放大至最大 或者 缩小至最小
    @objc func handleDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        
        if imageView.image == nil { return }
        
        if scrollView.zoomScale <= scrollView.minimumZoomScale { // 放大
            
            let location = tapGesture.location(in: scrollView)
            
            let width = scrollView.frame.width / scrollView.maximumZoomScale
            let height = scrollView.frame.height / scrollView.maximumZoomScale
            
            let rect = CGRect(x: location.x * (1 - 1 / scrollView.maximumZoomScale), y: location.y * (1 - 1 / scrollView.maximumZoomScale), width: width, height: height)
            scrollView.zoom(to: rect, animated: true)
            
        } else {
            
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
}

// MARK:- Private Methods
fileprivate extension SDPhotoBrowserCollectionViewCell {
    
    func resetUI() {
        
        scrollView.zoomScale = scrollView.minimumZoomScale
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        imageView.image = nil
        singleTapImageClosure = nil
    }

    func setupImageViewFrame() {
        
        if let image = imageView.image {
            
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
            
            let width = image.size.width < scrollView.frame.width ? image.size.width : scrollView.frame.width
            let height = image.size.height * (width / image.size.width)
            
            if height > scrollView.frame.height {
                imageView.frame = CGRect(x: (scrollView.frame.width - width) / 2, y: 0.0, width: width, height: height)
                scrollView.contentSize = imageView.bounds.size
                scrollView.contentOffset = CGPoint.zero
                
            } else {
                
                imageView.frame = CGRect(x: (scrollView.frame.width - width) / 2, y: (scrollView.frame.height - height) / 2, width: width, height: height)
                
                scrollView.contentSize = imageView.bounds.size
            }
    
            scrollView.maximumZoomScale = scrollView.frame.height / height + 1.0
        }
    }
    
    func setImageViewToTheCenter() {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width)*0.5 : 0.0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height)*0.5 : 0.0
        
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}

// MARK:- UIScrollViewDelegate
extension SDPhotoBrowserCollectionViewCell: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        setImageViewToTheCenter()
    }
}


