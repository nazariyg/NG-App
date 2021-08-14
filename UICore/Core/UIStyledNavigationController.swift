// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

class UIStyledNavigationController: UINavigationController {

    private var navigationBarIsAlreadyStyled = false

    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)

        if !hidden {
            styleNavigationBarIfNeeded()
        }
    }

    private func styleNavigationBarIfNeeded() {
        guard !navigationBarIsAlreadyStyled else { return }

        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIConfig.navigationBarBackgroundColor

        navigationBar.titleTextAttributes = [
            .font: UIConfig.navigationBarTitleFont,
            .foregroundColor: UIConfig.navigationBarTitleColor,
            .kern: UIConfig.navigationBarTitleKerning
        ]

        navigationBar.removeBottomBorder()
        navigationBar.setShadow(
            ofSize: UIConfig.navigationBarShadowSize, opacity: UIConfig.navigationBarShadowAlpha, color: UIConfig.navigationBarShadowColor)

        navigationBarIsAlreadyStyled = true
    }

}
