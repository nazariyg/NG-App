// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

open class UILabelBase: UILabel {

    public override var text: String? {
        get {
            return super.text
        }

        set(value) {
            // For `UILabel`, we should first set the attributed text, if needed, preserving the style.
            if let attributedString = attributedText?.mutableCopy() as? NSMutableAttributedString {
                guard let text = value else {
                    attributedText = nil
                    return
                }
                attributedString.mutableString.setString(text)
                attributedText = attributedString
            }

            super.text = value
        }
    }

}
