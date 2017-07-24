//
//  SDCommon.swift
//  SDPhotoBrowser
//
//  Created by Sunny on 2017/3/17.
//  Copyright © 2017年 Sunny. All rights reserved.
//

import UIKit

public let kSDScreenWidth: CGFloat = UIScreen.main.bounds.width

public let kSDScreenHeight: CGFloat = UIScreen.main.bounds.height

public let kSDPhotoBrowserMargin: CGFloat = 15

public let kSDNavigationBarHeight: CGFloat = 64

public let kSDAnimationDuration: TimeInterval = 0.25

extension UICollectionReusableView {
    
    public static var sd_reuseIdentifier: String {
        
        let className = NSStringFromClass(self.classForCoder())
        let array = className.components(separatedBy: ".")
        let name = array.last!
        return name
    }
}

extension UIImage {

    class func sd_resource(named name: String) -> UIImage? {
    
        guard let bundlePath = Bundle.main.resourcePath?.appending("/Resource.Bundle") else { return nil }
        
        return UIImage(named:name, in: Bundle(path: bundlePath), compatibleWith: nil)
    }
}

protocol SDPhotoBrowserCellConfigProtocol {
    
    func sd_config(of url: URL?, withIndexPath indexPath: IndexPath)
}
