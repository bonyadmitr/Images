//
//  UIApplication+Settings.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

extension UIApplication {
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl)
            else { return }
        UIApplication.shared.openURL(settingsUrl)
    }
}
