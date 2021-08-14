// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift

public class UIButtonBase: UIButton {

    private static let disablingUserInteractionOnTapTimeInterval: TimeInterval = 0.2

    private let disablingUserInteractionOnTapDisposable = AutoDisposable()

    // MARK: - Lifecycle

    public convenience init() {
        self.init(frame: .zero)

        isExclusiveTouch = true

        if temporarilyDisableUserInteractionOnPress {
            wireInForDisablingUserInteractionOnTap()
        }
    }

    // MARK: - Title

    public override func setTitle(_ title: String?, for state: UIControl.State) {
        var useTitle = title

        if UIConfig.buttonTitleIsUppercased {
            useTitle = useTitle?.uppercased()
        }

        super.setTitle(useTitle, for: state)

        // Also set the attributed title if needed, preserving the style.
        if let attributedTitle = attributedTitle(for: state)?.mutableCopy() as? NSMutableAttributedString {
            guard let title = useTitle else {
                setAttributedTitle(nil, for: state)
                return
            }
            attributedTitle.mutableString.setString(title)
            setAttributedTitle(attributedTitle, for: state)
        }
    }

    // MARK: - Miscellaneous

    public var temporarilyDisableUserInteractionOnPress = true {
        didSet(oldValue) {
            guard temporarilyDisableUserInteractionOnPress != oldValue else { return }

            if temporarilyDisableUserInteractionOnPress {
                wireInForDisablingUserInteractionOnTap()
            } else {
                disablingUserInteractionOnTapDisposable.dispose()
            }
        }
    }

    // MARK: - Private

    private func wireInForDisablingUserInteractionOnTap() {
        disablingUserInteractionOnTapDisposable <=
            rx.tap
            .do(onNext: { [weak self] _ in self?.isUserInteractionEnabled = false })
            .debounce(Self.disablingUserInteractionOnTapTimeInterval, scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isUserInteractionEnabled = true })
            .subscribe()
    }

}
