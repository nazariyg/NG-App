// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

open class UIKeyboardDismissibleView: UIView {

    public var keyboardDismissingEnabled = true

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard keyboardDismissingEnabled else { return }
        endEditing(true)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

}
