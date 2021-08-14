// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Core
import RxSwift

/// UI events view subclasses.

// MARK: - UIView

open class UIInfoViewBase: UIView {

    public let didLayoutSubviewsWithinNonZeroBoundsOnce: O<Void>
    public let didLayoutSubviewsWithinNonZeroBounds: O<Void>
    private let _didLayoutSubviewsWithinNonZeroBounds = V<CGRect?>(nil)

    public private(set) lazy var isVisible = P(_isVisible.distinctUntilChanged())
    private let _isVisible = V<Bool>(false)

    public override init(frame: CGRect) {
        didLayoutSubviewsWithinNonZeroBounds =
            _didLayoutSubviewsWithinNonZeroBounds
            .filterNil()
            .mapToVoid()

        didLayoutSubviewsWithinNonZeroBoundsOnce =
            didLayoutSubviewsWithinNonZeroBounds
            .take(1)

        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds != .zero else { return }
        _didLayoutSubviewsWithinNonZeroBounds.value = bounds
    }

    open override func didMoveToWindow() {
        _isVisible.value = window != nil
    }

}

// MARK: - UIControl

open class UIInfoControlBase: UIControl {

    public let didLayoutSubviewsWithinNonZeroBoundsOnce: O<Void>
    public let didLayoutSubviewsWithinNonZeroBounds: O<Void>
    private let _didLayoutSubviewsWithinNonZeroBounds = V<CGRect?>(nil)

    public private(set) lazy var isVisible = P(_isVisible.distinctUntilChanged())
    private let _isVisible = V<Bool>(false)

    public override init(frame: CGRect) {
        didLayoutSubviewsWithinNonZeroBounds =
            _didLayoutSubviewsWithinNonZeroBounds
            .filterNil()
            .mapToVoid()

        didLayoutSubviewsWithinNonZeroBoundsOnce =
            didLayoutSubviewsWithinNonZeroBounds
            .take(1)

        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds != .zero else { return }
        _didLayoutSubviewsWithinNonZeroBounds.value = bounds
    }

    open override func didMoveToWindow() {
        _isVisible.value = window != nil
    }

}

// MARK: - UITableViewCell

open class UIInfoTableViewCellBase: UITableViewCell {

    public let didLayoutSubviewsWithinNonZeroBoundsOnce: O<Void>
    public let didLayoutSubviewsWithinNonZeroBounds: O<Void>
    private let _didLayoutSubviewsWithinNonZeroBounds = V<CGRect?>(nil)

    public private(set) lazy var isVisible = P(_isVisible.distinctUntilChanged())
    private let _isVisible = V<Bool>(false)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        didLayoutSubviewsWithinNonZeroBounds =
            _didLayoutSubviewsWithinNonZeroBounds
            .filterNil()
            .mapToVoid()

        didLayoutSubviewsWithinNonZeroBoundsOnce =
            didLayoutSubviewsWithinNonZeroBounds
            .take(1)

        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds != .zero else { return }
        _didLayoutSubviewsWithinNonZeroBounds.value = bounds
    }

    open override func didMoveToWindow() {
        _isVisible.value = window != nil
    }

}

// MARK: - UICollectionViewCell

open class UIInfoCollectionViewCellBase: UICollectionViewCell {

    public let didLayoutSubviewsWithinNonZeroBoundsOnce: O<Void>
    public let didLayoutSubviewsWithinNonZeroBounds: O<Void>
    private let _didLayoutSubviewsWithinNonZeroBounds = V<CGRect?>(nil)

    public private(set) lazy var isVisible = P(_isVisible.distinctUntilChanged())
    private let _isVisible = V<Bool>(false)

    public override init(frame: CGRect) {
        didLayoutSubviewsWithinNonZeroBounds =
            _didLayoutSubviewsWithinNonZeroBounds
            .filterNil()
            .mapToVoid()

        didLayoutSubviewsWithinNonZeroBoundsOnce =
            didLayoutSubviewsWithinNonZeroBounds
            .take(1)

        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds != .zero else { return }
        _didLayoutSubviewsWithinNonZeroBounds.value = bounds
    }

    open override func didMoveToWindow() {
        _isVisible.value = window != nil
    }

}
