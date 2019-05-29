//
//  UINavigationController+StatusBar.swift
//  Find It
//
//  Created by Marcos Ortiz on 5/29/19.
//  Copyright © 2019 Camden Developers. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
