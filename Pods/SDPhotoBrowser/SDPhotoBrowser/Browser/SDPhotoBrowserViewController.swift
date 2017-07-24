//
//  SDPhotoBrowserViewController.swift
//  lolbox
//
//  Created by Sunny on 2017/3/1.
//  Copyright © 2017年 duowan. All rights reserved.
//

import UIKit


enum SDButtonPosition: Int {
    case leftOne  = 1
    case leftTwo  = 2
    case rightOne = 3
    case rightTwo = 4
}


@objc protocol SDPhotoBrowserViewControllerDelegate: class {
    
    @objc optional func toolViewHeight(for photoBrowser: SDPhotoBrowserViewController) -> CGFloat
    
    @objc optional func customToolView(for photoBrowser: SDPhotoBrowserViewController) -> UIView
    
    @objc optional func photoBrowser(_ photoBrowser: SDPhotoBrowserViewController, didChangedToPageAtIndex index: Int)
}

class SDPhotoBrowserViewController: UIViewController {

    fileprivate lazy var collectionView: UICollectionView = {[unowned self] in
        
        let customFlowLayout = UICollectionViewFlowLayout()
        customFlowLayout.scrollDirection = .horizontal
        customFlowLayout.minimumLineSpacing = 0
        customFlowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: kSDScreenWidth + kSDPhotoBrowserMargin, height: kSDScreenHeight), collectionViewLayout: customFlowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(SDPhotoBrowserCollectionViewCell.self, forCellWithReuseIdentifier: SDPhotoBrowserCollectionViewCell.sd_reuseIdentifier)
        return collectionView
    }()
    
    fileprivate lazy var navBar: SDNavBar = { [unowned self] in
    
        let navBar = SDNavBar()
        navBar.isHidden = self.isHiddenNavBar
        navBar.navBarButtonType = self.navBarButtonType
        navBar.letfOneButtonClosure = {
            
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        return navBar
    }()
    
    fileprivate let SDPhotoBrowserAnimationDuration: TimeInterval = 0.35
    
    fileprivate var isShownavBar: Bool = false
    
    fileprivate var navBarTopMarginConstraint: NSLayoutConstraint!
    
    fileprivate var toolViewBottomMarginConstraint: NSLayoutConstraint?
    
    fileprivate var toolViewHeight: CGFloat = 0

    fileprivate var toolView: UIView?
    
    fileprivate var startIndex: Int = 0
    
    fileprivate var isOritenting = false
    
    fileprivate var currentIndex: Int = 0
    
    var delegate: SDPhotoBrowserViewControllerDelegate?
    
    var photoUrlArray: [URL]?
    
    // Default false
    var isHiddenNavBar: Bool = false
    
    var navBarButtonType: SDNavBarButtonType = .type1_0 {
    
        didSet {
            navBar.navBarButtonType = navBarButtonType
        }
    }
    
    // System Methods
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }

    
    public init(WithPhotoUrlArray photoUrlArray: [URL]?, startIndex: Int, delegate: SDPhotoBrowserViewControllerDelegate?) {
        
        self.photoUrlArray = photoUrlArray
        self.startIndex = startIndex
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- Lifecycle
extension SDPhotoBrowserViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor.black
        automaticallyAdjustsScrollViewInsets = false
        
        if let delegate = self.delegate, let toolViewHeight = delegate.toolViewHeight?(for: self), let toolView = delegate.customToolView?(for: self) {
            
            self.toolView = toolView
            self.toolViewHeight = toolViewHeight
            view.addSubview(toolView)
            
            delegate.photoBrowser?(self, didChangedToPageAtIndex: self.currentIndex)
        }
        
        collectionView.scrollToItem(at: IndexPath(item: self.startIndex, section: 0), at: .left, animated: false)
        
        self.view.addSubview(collectionView)
        self.view.addSubview(navBar)
        setupFrame()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.alpha = 0.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isOritenting {
            
            scrollTo(self.currentIndex)
            isOritenting = false
            
            if let navigationBar = self.navigationController?.navigationBar {
                navigationBar.alpha = 0.0
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        isOritenting = true
        
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

// MARK:- Public Methods
extension SDPhotoBrowserViewController {
    
    func configNavBarButton(named name: String, of position: SDButtonPosition, callBack: (() -> Void)?) {
        
        switch position {
        case .leftOne:
            navBar.leftOneButton.setImage(UIImage(named: name), for: .normal)
            navBar.letfOneButtonClosure = callBack
        case .leftTwo:
            navBar.leftTwoButton.setImage(UIImage(named: name), for: .normal)
            navBar.letfTwoButtonClosure = callBack
        case .rightOne:
            navBar.rightOneButton.setImage(UIImage(named: name), for: .normal)
            navBar.rightOneButtonClosure = callBack
        case .rightTwo:
            navBar.rightTwoButton.setImage(UIImage(named: name), for: .normal)
            navBar.rightTwoButtonClosure = callBack
        }
    }
    
}

// MARK:- Private Methods
fileprivate extension SDPhotoBrowserViewController {

    func setupFrame() {
    
        collectionView.collectionViewLayout.invalidateLayout()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: kSDPhotoBrowserMargin))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0))
        
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBarTopMarginConstraint = NSLayoutConstraint(item: navBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: -kSDNavigationBarHeight)
        view.addConstraint(navBarTopMarginConstraint)
        view.addConstraint(NSLayoutConstraint(item: navBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: navBar, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: navBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kSDNavigationBarHeight))
        
        
        if let toolView = self.toolView {
            
            view.bringSubview(toFront: toolView)
            toolView.translatesAutoresizingMaskIntoConstraints = false
            
            let bottomConstraint = NSLayoutConstraint(item: toolView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: toolViewHeight)
            toolViewBottomMarginConstraint = bottomConstraint
            
            view.addConstraint(bottomConstraint)
            view.addConstraint(NSLayoutConstraint(item: toolView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: toolView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: toolView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: toolViewHeight))
        }
    }
    
    func scrollTo(_ currentIndex: Int) {
        
        guard let photoUrlArray = self.photoUrlArray else { return }
        
        if currentIndex < 0 || currentIndex >= photoUrlArray.count { return }
        
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * collectionView.bounds.size.width, y: 0.0), animated: false)
    }
}

// MARK:- UICollectionViewDataSource
extension SDPhotoBrowserViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUrlArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SDPhotoBrowserCollectionViewCell.sd_reuseIdentifier, for: indexPath) as! SDPhotoBrowserCollectionViewCell
        cell.sd_config(of: photoUrlArray?[indexPath.item], withIndexPath: indexPath)
        cell.singleTapImageClosure = { [unowned self] (index) in
            
            self.isShownavBar = !self.isShownavBar
            
            UIView.animate(withDuration: kSDAnimationDuration, animations: { 
                
                if self.isShownavBar {
                    self.navBarTopMarginConstraint.constant = 0
                    self.toolViewBottomMarginConstraint?.constant = 0
                } else {
                    self.navBarTopMarginConstraint.constant = -kSDNavigationBarHeight
                    self.toolViewBottomMarginConstraint?.constant = self.toolViewHeight
                }
                self.view.layoutIfNeeded()
            })
        }
        return cell
    }
}


// MARK:- UICollectionViewDelegate
extension SDPhotoBrowserViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let delegate = self.delegate {
            delegate.photoBrowser?(self, didChangedToPageAtIndex: self.currentIndex)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        if let currentCell = cell as? SDPhotoBrowserCollectionViewCell {
            currentCell.resetZoomSacle()
        }
    }

}

// MARK:- UICollectionViewDelegateFlowLayout
extension SDPhotoBrowserViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
    }
}

