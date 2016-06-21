//
//  CustomTabBarProtocols.swift
//  CustomTabBar
//
//  Created by Ben Norris on 6/21/16.
//  Copyright © 2016 BSN Design. All rights reserved.
//

import UIKit

protocol CustomTabBarPresentable {
    var customTabBar: CustomTabBar { get }
}

protocol CustomTabBarAdjustible { }

extension CustomTabBarAdjustible where Self: UIViewController {
    
    func adjustForCustomTabBar(with scrollView: UIScrollView) {
        guard let tabController = tabBarController as? CustomTabBarPresentable else { return }
        let tabHeight = tabController.customTabBar.frame.size.height
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, tabHeight, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, tabHeight, 0)
    }
    
}
