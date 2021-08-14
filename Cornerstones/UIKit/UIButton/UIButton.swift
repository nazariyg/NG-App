// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

extension UIButton: StoredProperties {

    public var titleKerning: CGFloat {
        get {
            return (storedProperties.double[#function].map { CGFloat($0) }) ?? 0
        }

        set(value) {
            let string: String
            if let attributedText = attributedTitle(for: state) {
                string = attributedText.string
            } else if let titleLabelText = titleLabel?.text {
                string = titleLabelText
            } else {
                string = "\u{200b}"  // zero-width space
            }

            let attributedString = NSAttributedString(string: string, attributes: [.kern: value])
            setAttributedTitle(attributedString, for: .normal)
            storedProperties.double[#function] = Double(value)
        }
    }

}
