// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UILabel {

    var kerning: CGFloat {
        get {
            guard let kernValue = attributedText?.attribute(.kern, at: 0, effectiveRange: nil) as? NSNumber else { return 0 }
            return CGFloat(kernValue.doubleValue)
        }

        set(value) {
            let string: String
            if let attributedText = attributedText {
                string = attributedText.string
            } else if let text = text {
                string = text
            } else {
                string = "\u{200b}"  // zero-width space
            }

            let attributedString = NSAttributedString(string: string, attributes: [.kern: value])
            attributedText = attributedString
        }
    }

}
