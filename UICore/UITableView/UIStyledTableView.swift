// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

open class UIStyledTableView: UITableView {

    // MARK: - Lifecycle

    public override init(frame: CGRect, style: Style) {
        super.init(frame: frame, style: style)

        backgroundColor = .clear
        separatorStyle = .none
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    open override func didMoveToSuperview() {
        if let contentTone = baseViewController?.contentTone {
            switch contentTone {
            case .light: indicatorStyle = .black
            case .dark: indicatorStyle = .white
            }
        }
    }

}
