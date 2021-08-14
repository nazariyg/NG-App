// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift
import RxKeyboard
import Cartography

/// The base view controller to be subclassed by scene views. Supports scrolling the content by keyboard appearance, dismissing the keyboard on tap
/// within the non-control area of the content view, animated showing and hiding of the navigation bar and the status bar, tinting the status bar and
/// scroll indicators depending on the tone of the content.

open class UIViewControllerBase: UIViewController {

    public private(set) var contentView: UIView!

    public enum ContentTone {
        case light
        case dark
    }

    /// For custom content view types.
    open var contentViewType: UIView.Type? { return nil }

    public var scrollsByKeyboardShowUp = true
    public var scrollingByKeyboardContentOffsetFactor: CGFloat = 0.25
    public var dismissesKeyboardOnTap = true
    public var displaysNavigationBar = false
    public var displaysStatusBar = true
    public var keyboardAppearance: UIKeyboardAppearance?
    public var keyboardScrollViewHasScrollIndicators = false
    public var keyboardScrollViewIndicatorStyle: UIScrollView.IndicatorStyle = .default
    public var displaysTabBar = true
    public var contentTone: ContentTone?  // if set, overrides the style settings above
    public var statusBarStyle: UIStatusBarStyle?
    public var statusBarUpdateAnimation: UIStatusBarAnimation?
    public var interactiveDismissalEnabled = false
    public var usesBackgroundBlurForSheetTransition = true
    public var usesHeavyDimmingForSheetTransition = false
    public var coversWithSnapshotOnWillDisappear = false
    public private(set) var keyboardScrollView: UIScrollView!

    public let isShown = V<Bool>(false)

    private static let statusBarUpdateAnimationDuration: TimeInterval = 0.33
    private static let backgroundViewHeightMultiplier: CGFloat = 5

    private var isCurrentlySubstitutingPrefersStatusBarHidden = false
    private var overriddenTitle: String?
    private var snapshotCoverView: UIView?
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    open func initialize() {
        // To be overriden by subclassing view controllers. This method is invoked after the view is loaded by `UIViewControllerBase`.
        // To be used instead of `viewDidLoad`. No need to call `super.initialize`.
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        loadViewIfNeeded()

        addChrome()

        // Subclass view controller initialization.
        initialize()

        insertBackgroundView()

        if scrollsByKeyboardShowUp {
            wireInKeyboard()
            setKeyboardScrollViewIndicatorStyle()
        } else {
            keyboardScrollView.isScrollEnabled = false
        }

        if let keyboardDismissibleView = contentView as? UIKeyboardDismissibleView {
            keyboardDismissibleView.keyboardDismissingEnabled = dismissesKeyboardOnTap
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Public

    @discardableResult
    public func addSnapshotCoverView(afterScreenUpdates: Bool = true) -> UIView? {
        snapshotCoverView?.removeFromSuperview()

        guard let snapshotCoverView = contentView.snapshotView(afterScreenUpdates: afterScreenUpdates) else {
            assertionFailure()
            return nil
        }
        view.addSubview(snapshotCoverView)

        return snapshotCoverView
    }

    public func removeSnapshotCoverView() {
        snapshotCoverView?.removeFromSuperview()
        snapshotCoverView = nil
    }

    // MARK: - Private

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    private func setKeyboardScrollViewIndicatorStyle() {
        guard keyboardScrollViewHasScrollIndicators else {
            keyboardScrollView.showsVerticalScrollIndicator = false
            return
        }

        if let contentTone = contentTone {
            switch contentTone {
            case .light: keyboardScrollView.indicatorStyle = .black
            case .dark: keyboardScrollView.indicatorStyle = .white
            }
        } else {
            keyboardScrollView.indicatorStyle = keyboardScrollViewIndicatorStyle
        }
    }

    private func addChrome() {
        edgesForExtendedLayout = []

        let rootScrollView = UIScrollView()
        view.addSubview(rootScrollView)
        constrain(rootScrollView, view) { view, superview in
            view.edges == superview.edges
        }
        rootScrollView.contentInsetAdjustmentBehavior = .never
        self.keyboardScrollView = rootScrollView

        let contentView: UIView
        if let contentViewType = contentViewType {
            contentView = contentViewType.init()
        } else {
            contentView = UIKeyboardDismissibleView()
        }

        rootScrollView.addSubview(contentView)
        constrain(contentView, rootScrollView) { view, superview in
            view.edges == superview.edges
            view.center == superview.center
        }
        self.contentView = contentView
    }

    private func insertBackgroundView() {
        let backgroundView = UIView()
        if let contentViewBackgroundColor = contentView.backgroundColor {
            backgroundView.backgroundColor = contentViewBackgroundColor
        } else {
            backgroundView.backgroundColor = UIConfig.screenDefaultBackgroundColor
        }

        view.insertSubview(backgroundView, at: 0)
        constrain(backgroundView, view) { view, superview in
            view.center == superview.center
            view.width == superview.width
            view.height == superview.height*Self.backgroundViewHeightMultiplier
        }
    }

    // MARK: - Appearance

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        handleSnapshotCoverViewOnWillAppear()
        handleNavigationBar()
        handleStatusBar()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isShown.value = true
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleSnapshotCoverViewOnWillDisappear()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isShown.value = false
    }

    open func handleNavigationBar() {
        navigationController?.setNavigationBarHidden(!displaysNavigationBar, animated: true)
    }

    private func handleSnapshotCoverViewOnWillDisappear() {
        guard coversWithSnapshotOnWillDisappear else { return }
        addSnapshotCoverView()
    }

    private func handleSnapshotCoverViewOnWillAppear() {
        guard coversWithSnapshotOnWillDisappear else { return }
        removeSnapshotCoverView()
    }

    private func handleStatusBar() {
        isCurrentlySubstitutingPrefersStatusBarHidden = true
        UIView.animate(withDuration: Self.statusBarUpdateAnimationDuration,
            animations: { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }, completion: { [weak self] _ in
                self?.isCurrentlySubstitutingPrefersStatusBarHidden = false
            })
    }

    // MARK: - Scrolling on keyboard appearance

    private func wireInKeyboard() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self = self else { return }

                guard
                    self.scrollsByKeyboardShowUp,
                    self.children.isEmpty,
                    let rootScrollView = self.keyboardScrollView,
                    self.containsCurrentFirstResponder
                else { return }

                var extraBottomScrollInsets: CGFloat = 0
                if let window = rootScrollView.window {
                    extraBottomScrollInsets = window.bounds.height - rootScrollView.frame.height
                }

                if keyboardHeight > 0 {
                    with(rootScrollView) {
                        $0.contentInset.bottom = keyboardHeight
                        $0.scrollIndicatorInsets.top = rootScrollView.safeAreaInsets.top
                        $0.scrollIndicatorInsets.bottom = keyboardHeight - extraBottomScrollInsets
                        $0.setContentOffset(CGPoint(x: 0, y: keyboardHeight*self.scrollingByKeyboardContentOffsetFactor), animated: true)
                    }
                } else {
                    with(rootScrollView) {
                        $0.contentInset.bottom = 0
                        $0.scrollIndicatorInsets.top = 0
                        $0.scrollIndicatorInsets.bottom = 0
                        $0.setContentOffset(.zero, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Tab bar

    open func tabBarWillHide() {
        // Overridable.
    }

    // MARK: - Navigation controller

    public override var title: String? {
        get {
            return overriddenTitle
        }

        set(value) {
            overriddenTitle = value
            if !UIConfig.navigationBarTitleIsUppercased {
                super.title = overriddenTitle
            } else {
                super.title = overriddenTitle?.uppercased()
            }
        }
    }

    // MARK: - UIKit

    open override var prefersStatusBarHidden: Bool {
        if !isCurrentlySubstitutingPrefersStatusBarHidden {
            return UIApplication.shared.isStatusBarHidden
        } else {
            return !displaysStatusBar
        }
    }

    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let contentTone = contentTone {
            switch contentTone {
            case .light:
                if #available(iOS 13.0, *) {
                    return .darkContent
                } else {
                    return .default
                }
            case .dark:
                return .lightContent
            }
        } else {
            return statusBarStyle ?? super.preferredStatusBarStyle
        }
    }

}
