// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Cartography
import Core
import RxSwift

// MARK: - Protocol

public protocol UIRootContainerProtocol {

    func setRootViewController(_ viewController: UIViewController)
    func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle)
    func setRootViewController(_ viewController: UIViewController, completion: VoidClosure?)
    func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)
    func containerView(forKey key: String, isUserInteractionEnabled: Bool) -> UIView

    func pauseUserInteractionForTimeInterval(_ timeInterval: TimeInterval)
    func disableUserInteraction()
    func enableUserInteraction()

    var view: UIView! { get }
    var presentedViewController: UIViewController? { get }

}

// MARK: - Implementation

/// The parent view controller to contain any current root view controller. Allows for reducing memory footprint by replacing an existing
/// root view controller and its stack of presented/pushed view controllers with another one. Unlike with `UIWindow`, this offers the
/// added flexibility of animated transitions and global overlay views for e.g. network status notifications and in-app notifications.
public final class UIRootContainer: UIViewController, UIRootContainerProtocol, SharedInstance {

    public typealias InstanceProtocol = UIRootContainerProtocol
    public static func defaultInstance() -> InstanceProtocol { return UIRootContainer() }
    public static let doesReinstantiate = false  // the root of all UI should persist

    private static let supercontainerWindowLevel = UIWindow.Level.statusBar

    private var rootViewController: UIViewController?
    private var rootContainer: UIView!
    private var containerViewsSupercontainerWindow: UIWindow!
    private var containerViewsSupercontainerView: UIPassthroughView!
    private var containerKeysToViews: [String: UIView] = [:]
    private var userInteractionIsPaused = false
    private var userInteractionIsStopped = false
    private let pausingUserInteractionDisposable = AutoDisposable()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIConfig.appWindowBackgroundColor

        addRootContainer()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIState.setRootContainerDidAppear.value = true
    }

    // MARK: - Root view controller

    private func addRootContainer() {
        rootContainer = UIView()
        view.addSubview(rootContainer)

        rootContainer.frame = view.bounds
        rootContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    public func setRootViewController(_ viewController: UIViewController) {
        setRootViewController(viewController, transitionStyle: .defaultSet)
    }

    public func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle) {
        setRootViewController(viewController, transitionStyle: transitionStyle, completion: nil)
    }

    public func setRootViewController(_ viewController: UIViewController, completion: VoidClosure?) {
        setRootViewController(viewController, transitionStyle: .defaultSet, completion: completion)
    }

    public func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {
        DispatchQueue.syncSafeOnMain {
            loadViewIfNeeded()

            if let previousViewController = rootViewController {
                if transitionStyle == .setAfterSplashScreen,
                   let transitionAnimation = transitionStyle.transition?.childViewControllerReplacementAnimation {

                    addChild(viewController)
                    rootContainer.addSubview(viewController.view)
                    viewController.view.frame = rootContainer.bounds
                    viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    viewController.didMove(toParent: self)
                    rootViewController = viewController

                    rootContainer.insertSubview(previousViewController.view, aboveSubview: viewController.view)
                    previousViewController.view.setShadow(ofSize: UIConfig.splashScreenHidingShadowSize, opacity: UIConfig.splashScreenHidingShadowOpacity)
                    previousViewController.view.clipsToBounds = false

                    viewController.view.transform =
                        .init(scaleX: UIConfig.splashScreenHidingPreviousScreenInitialScale, y: UIConfig.splashScreenHidingPreviousScreenInitialScale)

                    UIView.animate(
                        withDuration: transitionAnimation.duration, delay: transitionAnimation.delay, options: transitionAnimation.options,
                        animations: { [weak self] in
                            guard let self = self else { return }
                            previousViewController.view.transform = .init(translationX: 0, y: self.rootContainer.frame.height)
                            viewController.view.transform = .identity
                        }, completion: { _ in
                            previousViewController.willMove(toParent: nil)
                            previousViewController.view.removeFromSuperview()
                            previousViewController.removeFromParent()
                            completion?()
                        })

                } else if transitionStyle != .system,
                          transitionStyle != .immediateSet,
                          let transitionAnimation = transitionStyle.transition?.childViewControllerReplacementAnimation {

                    addChild(viewController)
                    viewController.view.frame = rootContainer.bounds
                    viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    previousViewController.willMove(toParent: nil)

                    transition(
                        from: previousViewController, to: viewController,
                        duration: transitionAnimation.duration, options: transitionAnimation.options, animations: nil,
                        completion: { [weak self] _ in
                            guard let self = self else { return }
                            previousViewController.view.removeFromSuperview()
                            previousViewController.removeFromParent()
                            viewController.didMove(toParent: self)
                            self.rootViewController = viewController
                            completion?()
                        })

                } else {
                    addChild(viewController)
                    viewController.view.frame = rootContainer.bounds
                    viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    previousViewController.willMove(toParent: nil)

                    transition(
                        from: previousViewController, to: viewController,
                        duration: 0, options: [], animations: nil,
                        completion: { [weak self] _ in
                            guard let self = self else { return }
                            previousViewController.view.removeFromSuperview()
                            previousViewController.removeFromParent()
                            viewController.didMove(toParent: self)
                            self.rootViewController = viewController
                            completion?()
                        })

                }

            } else {
                addChild(viewController)
                rootContainer.addSubview(viewController.view)
                viewController.view.frame = rootContainer.bounds
                viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                viewController.didMove(toParent: self)
                rootViewController = viewController
                completion?()

            }

            setNeedsStatusBarAppearanceUpdate()
        }
    }

    // MARK: - Container views

    private func addContainerViewsSupercontainerIfNeeded() {
        guard containerViewsSupercontainerView == nil else { return }

        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                containerViewsSupercontainerWindow = UIPassthroughWindow(windowScene: windowScene)
            }
        }
        if containerViewsSupercontainerWindow == nil {
            containerViewsSupercontainerWindow = UIPassthroughWindow()
        }

        containerViewsSupercontainerView = UIPassthroughView()
        withOptional(containerViewsSupercontainerWindow, containerViewsSupercontainerView) {
            $0.frame = UIScreen.main.bounds
            $0.windowLevel = Self.supercontainerWindowLevel
            $0.makeKeyAndVisible()

            $0.addSubview($1)
            $1.frame = $0.bounds
            $1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    public func containerView(forKey key: String, isUserInteractionEnabled: Bool) -> UIView {
        addContainerViewsSupercontainerIfNeeded()

        if let existingContainerView = containerKeysToViews[key] {
            return existingContainerView
        }

        let containerView = UIPassthroughView()
        containerView.isUserInteractionEnabled = isUserInteractionEnabled

        if let currentBackmostContainerView = containerViewsSupercontainerView.subviews.first {
            containerViewsSupercontainerView.insertSubview(containerView, belowSubview: currentBackmostContainerView)
        } else {
            containerViewsSupercontainerView.addSubview(containerView)
        }

        constrain(containerView, containerViewsSupercontainerView) { view, superview in
            view.edges == superview.edges
        }

        containerKeysToViews[key] = containerView
        return containerView
    }

    // MARK: - Enabling/disabling user interaction

    public func pauseUserInteractionForTimeInterval(_ timeInterval: TimeInterval) {
        DispatchQueue.syncSafeOnMain {
            guard !userInteractionIsStopped else { return }

            view.isUserInteractionEnabled = false
            userInteractionIsPaused = true

            pausingUserInteractionDisposable <=
                O<Void>.just(())
                .delay(timeInterval, scheduler: MainScheduler.instance)
                .subscribeOnNext { [weak self] in
                    guard let self = self else { return }

                    guard !self.userInteractionIsStopped else { return }

                    self.view.isUserInteractionEnabled = true
                    self.userInteractionIsPaused = false
                }
        }
    }

    public func disableUserInteraction() {
        DispatchQueue.syncSafeOnMain {
            guard !userInteractionIsStopped else { return }

            userInteractionIsPaused = false
            pausingUserInteractionDisposable.dispose()

            view.isUserInteractionEnabled = false
            userInteractionIsStopped = true
        }
    }

    public func enableUserInteraction() {
        DispatchQueue.syncSafeOnMain {
            view.isUserInteractionEnabled = true
            userInteractionIsStopped = false
        }
    }

    // MARK: - Event forwarding

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }

    public override var childForStatusBarHidden: UIViewController? {
        return rootViewController
    }

    public override var childForStatusBarStyle: UIViewController? {
        return rootViewController
    }

    public override var childForHomeIndicatorAutoHidden: UIViewController? {
        return rootViewController
    }

    public override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return rootViewController
    }

}
