//
//  BaseNavigationController.swift
//  Images
//
//  Created by Bondar Yaroslav on 10/02/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        removeBackShadow = true
    }
}

import UIKit

extension UINavigationController {
    /// to remove navigation bar shadow on back action
    /// https://stackoverflow.com/questions/22413193/dark-shadow-on-navigation-bar-during-segue-transition-after-upgrading-to-xcode-5
    @IBInspectable var removeBackShadow: Bool {
        get {
            return view.backgroundColor == UIColor.white
        }
        set {
            view.backgroundColor = UIColor.white
        }
    }
}
