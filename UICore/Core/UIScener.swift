// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift

// MARK: - Protocol

public protocol UIScenerProtocol {

    func initialize(initialSceneType: UIInitialScene.Type)
    func initialize(initialSceneType: UIInitialScene.Type, completion: VoidClosure?)
    func initialize(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int)
    func initialize(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int, completion: VoidClosure?)

    func next<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?)
    func next<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle)
    func next<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)

    func up<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?)
    func up<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle)
    func up<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)

    func set(_ initialSceneType: UIInitialScene.Type)
    func set(_ initialSceneType: UIInitialScene.Type, transitionStyle: UISceneTransitionStyle)
    func set(_ initialSceneType: UIInitialScene.Type, completion: VoidClosure?)
    func set(_ initialSceneType: UIInitialScene.Type, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)
    func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?)
    func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle)
    func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, completion: VoidClosure?)
    func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)
    func set(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int)
    func set(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int, completion: VoidClosure?)
    func set(
        tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int, transitionStyle: UISceneTransitionStyle,
        completion: VoidClosure?)

    func tab(tabIndex: Int)
    var currentTabIndex: P<Int> { get }

    func back()
    func back(completion: VoidClosure?)
    func _backTo<Scene: UISceneBase>(_ sceneType: Scene.Type, completion: @escaping ((_ didGoBack: Bool) -> Void))

    var willTransitionToSceneType: O<UISceneBase.Type> { get }
    var currentSceneType: P<UISceneBase.Type?> { get }

    // Invoked by `UIEmbeddingNavigationController` when an pushed scene is being dismissed via the native back button, without calling
    // any of dismissal methods of the `UIScener` directly, so that the `UIScener` could update its state of stacked scenes.
    func _popSceneIfNeeded(ifContainsNavigationItem navigationItem: UINavigationItem)

    // For presenting third-party view controllers.
    func _suspendTransitionQueue()
    func _resumeTransitionQueue()

}

// MARK: - Implementation

/// `UIScener` manages transitions between scenes with support for transition styles and tabs.
///
/// A "next" transition corresponds to pushing a view controller into a navigation controller, while an "up" transition corresponds to
/// a view controller being presented over another one. A "set" transition corresponds to replacing a root view controller with another
/// root view controller.
///
/// The view controller of every presented scene is automatically embedded into an `UIEmbeddingNavigationController` for that scene to
/// be able to make "next" (push) transitions further on, with the navigation bar hidden by default.
public final class UIScener: UIScenerProtocol, SharedInstance {

    public typealias InstanceProtocol = UIScenerProtocol
    public static func defaultInstance() -> InstanceProtocol { return UIScener() }
    public static let doesReinstantiate = false

    public private(set) lazy var currentTabIndex = P(_currentTabIndex.distinctUntilChanged())
    private let _currentTabIndex = V<Int>(0)

    private var sceneNodeStack: [[SceneNode]] = []
    private weak var tabsController: UITabsController?
    private var currentlyActiveTransition: UISceneTransition?
    private var sceneTransitionQueue = SerialQueue(qos: Config.shared.general.uiRelatedBackgroundQueueQoS)
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Initializing with scene types to be shown initially and for which no parameters are required

    /// Initializes the scener with an initial scene.
    public func initialize(initialSceneType: UIInitialScene.Type) {
        initialize(initialSceneType: initialSceneType, completion: nil)
    }

    /// Initializes the scener with an initial scene, calling a completion closure afterwards.
    public func initialize(initialSceneType: UIInitialScene.Type, completion: VoidClosure?) {
        enqueueTransitionSync { [weak self] in
            guard let self = self else { return }

            self.sceneTransitionQueue.suspend()

            _willTransitionToSceneType.send(initialSceneType)

            let initialScene = initialSceneType.init()

            let rootViewController = Self.embedInNavigationControllerIfNeeded(initialScene.viewController)

            let sceneNode = SceneNode(transitionType: .root, scene: initialScene, viewController: rootViewController, transitionStyle: nil)
            self.sceneNodeStack = [[sceneNode]]

            UIRootContainer.shared.setRootViewController(rootViewController, completion: { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self._currentSceneType.value = initialSceneType

                    self.sceneTransitionQueue.resume()

                    completion?()
                }
            })
        }
    }

    /// Initializes the scener with a set of initial scenes supervised by a tab controller.
    public func initialize(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int) {
        initialize(tabsControllerType: tabsControllerType, tabSceneTypes: tabSceneTypes, initialTabIndex: initialTabIndex, completion: nil)
    }

    /// Initializes the scener with a set of initial scenes supervised by a tab controller, calling a completion closure afterwards.
    public func initialize(
        tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int, completion: VoidClosure?) {

        enqueueTransitionSync { [weak self] in
            guard let self = self else { return }

            self.sceneTransitionQueue.suspend()

            _willTransitionToSceneType.send(tabSceneTypes[initialTabIndex])

            let initialScenes = tabSceneTypes.map { sceneType in sceneType.init() }
            let viewControllers = initialScenes.map { scene in Self.embedInNavigationControllerIfNeeded(scene.viewController) }

            let tabsController = tabsControllerType.init()
            tabsController.viewControllers = viewControllers
            tabsController.selectedIndex = initialTabIndex
            self.tabsController = tabsController

            self.sceneNodeStack =
                initialScenes.enumerated().map { index, scene in
                    return [SceneNode(transitionType: .root, scene: scene, viewController: viewControllers[index], transitionStyle: nil)]
                }
            self._currentTabIndex.value = initialTabIndex

            UIRootContainer.shared.setRootViewController(tabsController as! UIViewController, transitionStyle: .immediateSet, completion: { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self._currentSceneType.value = tabSceneTypes[initialTabIndex]

                    self.sceneTransitionQueue.resume()

                    completion?()
                }
            })
        }
    }

    // MARK: - "Next" transitions

    /// Makes a "next" transition to a scene using the default transition style.
    public func next<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?) {
        next(Scene.self, parameters: parameters, transitionStyle: .defaultNext)
    }

    /// Makes a "next" transition to a scene using a specific transition style.
    public func next<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle) {
        next(Scene.self, parameters: parameters, transitionStyle: transitionStyle, completion: nil)
    }

    /// Makes a "next" transition to a scene using a specific transition style, calling a completion closure afterwards.
    public func next<Scene: UICore.UIScene>(
        _ sceneType: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {

        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            guard !(self.currentSceneNode.scene is Scene) else { return }

            self.sceneTransitionQueue.suspend()

            guard let navigationController = self.currentSceneNode.scene.viewController.navigationController else {
                assertionFailure()
                return
            }

            let scene = Scene(parameters: parameters)
            let viewController = scene.viewController

            if !transitionStyle.affectsEntireScreen {
                if let currentBaseViewController = self.currentSceneNode.scene.viewController as? UIViewControllerBase,
                   let nextBaseViewController = viewController as? UIViewControllerBase {

                    if currentBaseViewController.displaysTabBar != nextBaseViewController.displaysTabBar {
                        if let tabsController = self.tabsController {
                            if currentBaseViewController.displaysTabBar {
                                currentBaseViewController.tabBarWillHide()
                            }
                            if nextBaseViewController.displaysTabBar {
                                tabsController.showTabBar()
                            } else {
                                tabsController.hideTabBar()
                            }
                        }
                    }
                }
            }

            let sceneNode = SceneNode(transitionType: .next, scene: scene, viewController: viewController, transitionStyle: transitionStyle)
            self.pushSceneNode(sceneNode)

            self._willTransitionToSceneType.send(sceneType)

            self.makeNextTransition(
                navigationController: navigationController, viewController: viewController, toScenes: [scene], transition: sceneNode.cachedTransition,
                completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self._currentSceneType.value = sceneType

                        self.sceneTransitionQueue.resume()

                        completion?()
                    }
                })
        }
    }

    // MARK: - "Up" transitions

    /// Makes an "up" transition to a scene using the default transition style.
    public func up<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?) {
        up(Scene.self, parameters: parameters, transitionStyle: .defaultUp)
    }

    /// Makes an "up" transition to a scene using a specific transition style.
    public func up<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle) {
        up(Scene.self, parameters: parameters, transitionStyle: transitionStyle, completion: nil)
    }

    /// Makes an "up" transition to a scene using a specific transition style, calling a completion closure afterwards.
    public func up<Scene: UICore.UIScene>(
        _ sceneType: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {

        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            guard !(self.currentSceneNode.scene is Scene) else { return }

            self.sceneTransitionQueue.suspend()

            let scene = Scene(parameters: parameters)
            let viewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

            if !transitionStyle.affectsEntireScreen {
                if let currentBaseViewController = self.currentSceneNode.scene.viewController as? UIViewControllerBase,
                   let nextBaseViewController = scene.viewController as? UIViewControllerBase {

                    if currentBaseViewController.displaysTabBar != nextBaseViewController.displaysTabBar {
                        if let tabsController = self.tabsController {
                            if currentBaseViewController.displaysTabBar {
                                currentBaseViewController.tabBarWillHide()
                            }
                            if nextBaseViewController.displaysTabBar {
                                tabsController.showTabBar()
                            } else {
                                tabsController.hideTabBar()
                            }
                        }
                    }
                }
            }

            let sceneNode = SceneNode(transitionType: .up, scene: scene, viewController: viewController, transitionStyle: transitionStyle)
            let currentScene = self.currentSceneNode.scene
            self.pushSceneNode(sceneNode)

            self._willTransitionToSceneType.send(sceneType)

            self.makeUpTransition(
                viewController: viewController, fromScene: currentScene, toScenes: [scene], transition: sceneNode.cachedTransition,
                completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self._currentSceneType.value = sceneType

                        self.sceneTransitionQueue.resume()

                        completion?()
                    }
                })
        }
    }

    // MARK: - "Set" transitions

    /// Makes a "set" transition to a scene using the default transition style.
    public func set(_ initialSceneType: UIInitialScene.Type) {
        set(initialSceneType, transitionStyle: .defaultSet, completion: nil)
    }

    /// Makes a "set" transition to a scene using a specific transition style.
    public func set(_ initialSceneType: UIInitialScene.Type, transitionStyle: UISceneTransitionStyle) {
        set(initialSceneType, transitionStyle: transitionStyle, completion: nil)
    }

    /// Makes a "set" transition to a scene, calling a completion closure afterwards.
    public func set(_ initialSceneType: UIInitialScene.Type, completion: VoidClosure?) {
        set(initialSceneType, transitionStyle: .defaultSet, completion: completion)
    }

    /// Makes a "set" transition to a scene using a specific transition style, calling a completion closure afterwards.
    public func set(_ initialSceneType: UIInitialScene.Type, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {
        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            guard type(of: self.currentSceneNode.scene) != initialSceneType else { return }

            self.sceneTransitionQueue.suspend()

            if let presentedViewController = UIRootContainer.shared.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: nil)
            }

            let scene = initialSceneType.init()

            self.currentlyActiveTransition = nil

            self._willTransitionToSceneType.send(initialSceneType)

            if !transitionStyle.isNext &&
               !transitionStyle.isUp {

                let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                let sceneNode = SceneNode(transitionType: .root, scene: scene, viewController: rootViewController, transitionStyle: nil)
                self.sceneNodeStack = [[sceneNode]]
                self._currentTabIndex.value = 0

                scene.sceneIsInitialized
                    .observeOn(MainScheduler.instance)
                    .filter { $0 }
                    .take(1)
                    .subscribeOnNext { [weak self] _ in
                        UIRootContainer.shared.setRootViewController(
                            rootViewController, transitionStyle: transitionStyle, completion: { [weak self] in
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }

                                    self._currentSceneType.value = initialSceneType

                                    self.sceneTransitionQueue.resume()

                                    completion?()
                                }
                            })
                    }
                    .disposed(by: self.disposeBag)

            } else {
                let semiCompletion = { [weak self] in
                    guard let self = self else { return }
                    let transitionStyle: UISceneTransitionStyle = .immediateSet

                    let scene = initialSceneType.init()

                    let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                    let sceneNode = SceneNode(transitionType: .root, scene: scene, viewController: rootViewController, transitionStyle: nil)
                    self.sceneNodeStack = [[sceneNode]]
                    self._currentTabIndex.value = 0

                    scene.sceneIsInitialized
                        .observeOn(MainScheduler.instance)
                        .filter { $0 }
                        .take(1)
                        .subscribeOnNext { [weak self] _ in
                            UIRootContainer.shared.setRootViewController(
                                rootViewController, transitionStyle: transitionStyle, completion: { [weak self] in
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self = self else { return }

                                        self._currentSceneType.value = initialSceneType

                                        self.sceneTransitionQueue.resume()

                                        completion?()
                                    }
                                })
                        }
                        .disposed(by: self.disposeBag)
                }

                let currentScene = self.currentSceneNode.scene

                if transitionStyle.isNext {
                    guard let navigationController = currentScene.viewController.navigationController else {
                        assertionFailure()
                        return
                    }
                    let transition = UISceneTransitionStyle.defaultNext.transition
                    self.makeNextTransition(
                        navigationController: navigationController, viewController: scene.viewController, toScenes: [scene], transition: transition,
                        completion: semiCompletion)

                } else if transitionStyle.isUp {
                    let transition = UISceneTransitionStyle.defaultUp.transition
                    self.makeUpTransition(
                        viewController: scene.viewController, fromScene: currentScene, toScenes: [scene], transition: transition,
                        completion: semiCompletion)
                }
            }
        }
    }

    /// Makes a "set" transition to a scene using the default transition style.
    public func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?) {
        set(Scene.self, parameters: parameters, transitionStyle: .defaultSet, completion: nil)
    }

    /// Makes a "set" transition to a scene using a specific transition style.
    public func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle) {
        set(Scene.self, parameters: parameters, transitionStyle: transitionStyle, completion: nil)
    }

    /// Makes a "set" transition to a scene, calling a completion closure afterwards.
    public func set<Scene: UICore.UIScene>(_: Scene.Type, parameters: Scene.Parameters?, completion: VoidClosure?) {
        set(Scene.self, parameters: parameters, transitionStyle: .defaultSet, completion: completion)
    }

    /// Makes a "set" transition to a scene using a specific transition style, calling a completion closure afterwards.
    public func set<Scene: UICore.UIScene>(
        _ sceneType: Scene.Type, parameters: Scene.Parameters?, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {

        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            guard !(self.currentSceneNode.scene is Scene) else { return }

            self.sceneTransitionQueue.suspend()

            if let presentedViewController = UIRootContainer.shared.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: nil)
            }

            let scene = Scene(parameters: parameters)

            self.currentlyActiveTransition = nil

            self._willTransitionToSceneType.send(sceneType)

            if !transitionStyle.isNext &&
               !transitionStyle.isUp {

                let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                let sceneNode = SceneNode(transitionType: .root, scene: scene, viewController: rootViewController, transitionStyle: nil)
                self.sceneNodeStack = [[sceneNode]]
                self._currentTabIndex.value = 0

                scene.sceneIsInitialized
                    .observeOn(MainScheduler.instance)
                    .filter { $0 }
                    .take(1)
                    .subscribeOnNext { [weak self] _ in
                        UIRootContainer.shared.setRootViewController(
                            rootViewController, transitionStyle: transitionStyle, completion: { [weak self] in
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }

                                    self._currentSceneType.value = sceneType

                                    self.sceneTransitionQueue.resume()

                                    completion?()
                                }
                            })
                    }
                    .disposed(by: self.disposeBag)

            } else {
                let semiCompletion = { [weak self] in
                    guard let self = self else { return }
                    let transitionStyle: UISceneTransitionStyle = .immediateSet

                    let scene = Scene(parameters: parameters)

                    let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                    let sceneNode = SceneNode(transitionType: .root, scene: scene, viewController: rootViewController, transitionStyle: nil)
                    self.sceneNodeStack = [[sceneNode]]
                    self._currentTabIndex.value = 0

                    scene.sceneIsInitialized
                        .observeOn(MainScheduler.instance)
                        .filter { $0 }
                        .take(1)
                        .subscribeOnNext { [weak self] _ in
                            UIRootContainer.shared.setRootViewController(
                                rootViewController, transitionStyle: transitionStyle, completion: { [weak self] in
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self = self else { return }

                                        self._currentSceneType.value = sceneType

                                        self.sceneTransitionQueue.resume()

                                        completion?()
                                    }
                                })
                        }
                        .disposed(by: self.disposeBag)
                }

                let currentScene = self.currentSceneNode.scene

                if transitionStyle.isNext {
                    guard let navigationController = currentScene.viewController.navigationController else {
                        assertionFailure()
                        return
                    }
                    let transition = UISceneTransitionStyle.defaultNext.transition
                    self.makeNextTransition(
                        navigationController: navigationController, viewController: scene.viewController, toScenes: [scene], transition: transition,
                        completion: semiCompletion)

                } else if transitionStyle.isUp {
                    let transition = UISceneTransitionStyle.defaultUp.transition
                    self.makeUpTransition(
                        viewController: scene.viewController, fromScene: currentScene, toScenes: [scene], transition: transition,
                        completion: semiCompletion)
                }
            }
        }
    }

    /// Makes a "set" transition to a tabs controller.
    public func set(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int) {
        set(tabsControllerType: tabsControllerType, tabSceneTypes: tabSceneTypes, initialTabIndex: initialTabIndex, transitionStyle: .defaultSet,
            completion: nil)
    }

    /// Makes a "set" transition to a tabs controller using a specific transition style.
    public func set(
        tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int, completion: VoidClosure?) {

        set(
            tabsControllerType: tabsControllerType, tabSceneTypes: tabSceneTypes, initialTabIndex: initialTabIndex, transitionStyle: .defaultSet,
            completion: completion)
    }

    /// Makes a "set" transition to a tabs controller using a specific transition style, calling a completion closure afterwards.
    public func set(
        tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int,
        transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {

        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            self.sceneTransitionQueue.suspend()

            if let presentedViewController = UIRootContainer.shared.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: nil)
            }

            let initialScenes = tabSceneTypes.map { sceneType in sceneType.init() }
            let viewControllers = initialScenes.map { scene in Self.embedInNavigationControllerIfNeeded(scene.viewController) }

            let tabsController = tabsControllerType.init()
            tabsController.viewControllers = viewControllers
            tabsController.selectedIndex = initialTabIndex
            let tabsControllerViewController = tabsController as! UIViewController

            self.currentlyActiveTransition = nil

            self._willTransitionToSceneType.send(tabSceneTypes[initialTabIndex])

            if !transitionStyle.isNext &&
               !transitionStyle.isUp {

                O.combineLatest(initialScenes.map({ $0.sceneIsInitialized }))
                    .observeOn(MainScheduler.instance)
                    .filter { $0.allSatisfy({ $0 }) }
                    .take(1)
                    .subscribeOnNext { [weak self] _ in
                        guard let self = self else { return }

                        self.sceneNodeStack =
                            initialScenes.enumerated().map { index, scene in
                                return [SceneNode(transitionType: .root, scene: scene, viewController: viewControllers[index], transitionStyle: nil)]
                            }
                        self._currentTabIndex.value = initialTabIndex
                        self.tabsController = tabsController

                        UIRootContainer.shared.setRootViewController(
                            tabsControllerViewController, transitionStyle: transitionStyle,
                            completion: { [weak self] in
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }

                                    self._currentSceneType.value = tabSceneTypes[initialTabIndex]

                                    self.sceneTransitionQueue.resume()

                                    completion?()
                                }
                            })
                    }
                    .disposed(by: self.disposeBag)

            } else {
                let semiCompletion = {
                    let transitionStyle: UISceneTransitionStyle = .immediateSet

                    let initialScenes = tabSceneTypes.map { sceneType in sceneType.init() }
                    let viewControllers = initialScenes.map { scene in Self.embedInNavigationControllerIfNeeded(scene.viewController) }

                    let tabsController = tabsControllerType.init()
                    tabsController.viewControllers = viewControllers
                    tabsController.selectedIndex = initialTabIndex
                    let tabsControllerViewController = tabsController as! UIViewController

                    O.combineLatest(initialScenes.map({ $0.sceneIsInitialized }))
                        .observeOn(MainScheduler.instance)
                        .filter { $0.allSatisfy({ $0 }) }
                        .take(1)
                        .subscribeOnNext { [weak self] _ in
                            guard let self = self else { return }

                            self.sceneNodeStack =
                                initialScenes.enumerated().map { index, scene in
                                    return [SceneNode(transitionType: .root, scene: scene, viewController: viewControllers[index], transitionStyle: nil)]
                                }
                            self._currentTabIndex.value = initialTabIndex
                            self.tabsController = tabsController

                            UIRootContainer.shared.setRootViewController(
                                tabsControllerViewController, transitionStyle: transitionStyle,
                                completion: { [weak self] in
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self = self else { return }

                                        self._currentSceneType.value = tabSceneTypes[initialTabIndex]

                                        self.sceneTransitionQueue.resume()

                                        completion?()
                                    }
                                })
                        }
                        .disposed(by: self.disposeBag)
                }

                let currentScene = self.currentSceneNode.scene

                if transitionStyle.isNext {
                    guard let navigationController = currentScene.viewController.navigationController else {
                        assertionFailure()
                        return
                    }
                    let transition = UISceneTransitionStyle.defaultNext.transition
                    self.makeNextTransition(
                        navigationController: navigationController, viewController: tabsControllerViewController, toScenes: initialScenes,
                        transition: transition, completion: semiCompletion)

                } else if transitionStyle.isUp {
                    let transition = UISceneTransitionStyle.defaultUp.transition
                    self.makeUpTransition(
                        viewController: tabsControllerViewController, fromScene: currentScene, toScenes: initialScenes,
                        transition: transition, completion: semiCompletion)
                }
            }
        }
    }

    // MARK: - "Tab" transitions

    /// Makes a "tab" transition to the scene that is currently topmost in the scene stack located at the specified tab index.
    public func tab(tabIndex: Int) {
        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            guard let tabsController = self.tabsController else {
                assertionFailure()
                return
            }

            guard tabIndex != tabsController.selectedIndex else { return }

            if let firstSceneNode = self.sceneNodeStack[self._currentTabIndex.value].first,
               let tabBarController = firstSceneNode.viewController.tabBarController,
               let transition = firstSceneNode.transitionStyle?.transition {

                self.currentlyActiveTransition = transition
                tabBarController.delegate = self.currentlyActiveTransition
            }

            let sceneType = type(of: self.sceneNodeStack[tabIndex].last!.scene)

            self._willTransitionToSceneType.send(sceneType)

            tabsController.selectedIndex = tabIndex

            self._currentTabIndex.value = tabIndex
            self._currentSceneType.value = type(of: self.currentSceneNode.scene)
        }
    }

    // MARK: - "Back" transitions

    /// Makes a "back" ("pop" or "dismiss") transition to the previous scene using the backward flavor of the transition style that was used
    /// to transition to the current scene, if any.
    public func back() {
        back(completion: nil)
    }

    /// Makes a "back" ("pop" or "dismiss") transition to the previous scene using the backward flavor of the transition style that was used
    /// to transition to the current scene, if any, and calling a completion closure afterwards.
    public func back(completion: VoidClosure?) {
        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            guard self.sceneNodeCount > 1 else { return }

            self.sceneTransitionQueue.suspend()

            if let currentBaseViewController = self.currentSceneNode.scene.viewController as? UIViewControllerBase,
               let nextBaseViewController = self.underlyingSceneNode?.scene.viewController as? UIViewControllerBase {

                if currentBaseViewController.displaysTabBar != nextBaseViewController.displaysTabBar {
                    if let tabsController = self.tabsController {
                        if currentBaseViewController.displaysTabBar {
                            currentBaseViewController.tabBarWillHide()
                        }
                        if nextBaseViewController.displaysTabBar {
                            tabsController.showTabBar()
                        } else {
                            tabsController.hideTabBar()
                        }
                    }
                }
            }

            switch self.currentSceneNode.transitionType {

            case .next:
                guard let navigationController = self.currentSceneNode.scene.viewController.navigationController else {
                    assertionFailure()
                    return
                }
                if self.currentSceneNode.transitionStyle != nil {
                    let transition = self.currentSceneNode.cachedTransition
                    self.currentlyActiveTransition = transition
                    navigationController.delegate = transition
                }

                let sceneType = type(of: self.backSceneNode.scene)

                self._willTransitionToSceneType.send(sceneType)

                self.popSceneNode()
                navigationController.popViewController(animated: true, completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.currentlyActiveTransition = nil
                        self._currentSceneType.value = type(of: self.currentSceneNode.scene)

                        self.sceneTransitionQueue.resume()

                        completion?()
                    }
                })

            case .up:
                guard let presentingViewController = self.currentSceneNode.viewController.presentingViewController else {
                    assertionFailure()
                    return
                }
                if self.currentSceneNode.transitionStyle != nil {
                    let transition = self.currentSceneNode.cachedTransition
                    self.currentlyActiveTransition = transition
                    self.currentSceneNode.viewController.transitioningDelegate = transition
                }

                let sceneType = type(of: self.backSceneNode.scene)

                self._willTransitionToSceneType.send(sceneType)

                self.popSceneNode()
                presentingViewController.dismiss(animated: true, completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.currentlyActiveTransition = nil
                        self._currentSceneType.value = type(of: self.currentSceneNode.scene)

                        self.sceneTransitionQueue.resume()

                        completion?()
                    }
                })

            default:
                assertionFailure()

            }
        }
    }

    /// Traverses the scene stack from the current scene back to the scene of the specified type and pops/dismisses the covering screen hierarchy
    /// to the target scene using the backward flavor of the push/present style that was used to transition from the target scene. It's only if
    /// the target scene was followed by one or more "next" transitions that were in turn followed by one or more "up" transitions when going back
    /// to that target scene is not supported. To be called by `UIGlobalSceneRouter` only.
    public func _backTo<Scene: UISceneBase>(_ sceneType: Scene.Type, completion: @escaping ((_ didGoBack: Bool) -> Void)) {
        enqueueTransitionAsync { [weak self] in
            self?.backTo(sceneType, animated: true, completion: completion)
        }
    }

    private func backTo<Scene: UISceneBase>(_ sceneType: Scene.Type, animated: Bool, completion: @escaping ((_ didGoBack: Bool) -> Void)) {
        guard !(currentSceneNode.scene is Scene) else {
            completion(false)
            return
        }

        sceneTransitionQueue.suspend()

        if currentSceneNode.transitionType == .next {
            // See if the target scene is part of any topmost chain of "next" transitions and, if so, pop to the target scene through that chain.
            let didPop = popBackToSceneInChainIfPossibleAndResumeSceneTransitionQueue(sceneType, animated: animated, completion: completion)
            if didPop { return }  // done going back if did pop
        }

        // Dismiss to the target scene.
        let didDismiss = dismissBackToSceneAndResumeSceneTransitionQueue(sceneType, animated: animated, completion: completion)
        if !didDismiss {
            assertionFailure()
            completion(false)
        }
    }

    private func popBackToSceneInChainIfPossibleAndResumeSceneTransitionQueue<Scene: UISceneBase>(
        _ sceneType: Scene.Type, animated: Bool, completion: @escaping ((_ didGoBack: Bool) -> Void)) -> Bool {

        let reversedNodeIndexes = (0..<(sceneNodeCount - 1)).reversed()

        for index in reversedNodeIndexes {
            let currentNodeStack = sceneNodeStack[_currentTabIndex.value]

            let underlyingSceneNode = currentNodeStack[index]
            guard underlyingSceneNode.scene is Scene else { continue }

            let overlayingSceneNode = currentNodeStack[index + 1]
            guard overlayingSceneNode.transitionType == .next else { return false }

            guard let navigationController = overlayingSceneNode.scene.viewController.navigationController else {
                assertionFailure()
                return false
            }

            if currentSceneNode.transitionStyle != nil {
                let transition = currentSceneNode.cachedTransition
                currentlyActiveTransition = transition
                navigationController.delegate = transition
            }

            sceneNodeStack[_currentTabIndex.value].removeSubrange((index + 1)...)

            _willTransitionToSceneType.send(sceneType)

            navigationController.popToViewController(
                underlyingSceneNode.scene.viewController, animated: animated,
                completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.currentlyActiveTransition = nil
                        self._currentSceneType.value = type(of: self.currentSceneNode.scene)

                        self.sceneTransitionQueue.resume()

                        completion(true)
                    }
                })

            return true
        }

        return false
    }

    private func dismissBackToSceneAndResumeSceneTransitionQueue<Scene: UISceneBase>(
        _ sceneType: Scene.Type, animated: Bool, completion: @escaping ((_ didGoBack: Bool) -> Void)) -> Bool {

        let reversedNodeIndexes = (0..<(sceneNodeCount - 1)).reversed()

        for index in reversedNodeIndexes {
            let currentNodeStack = sceneNodeStack[_currentTabIndex.value]

            let underlyingSceneNode = currentNodeStack[index]
            guard underlyingSceneNode.scene is Scene else { continue }

            let overlayingSceneNode = currentNodeStack[index + 1]
            guard overlayingSceneNode.transitionType == .up else { return false }

            guard let presentingViewController = overlayingSceneNode.viewController.presentingViewController else {
                assertionFailure()
                return false
            }

            if overlayingSceneNode.transitionStyle != nil {
                currentlyActiveTransition = overlayingSceneNode.cachedTransition
            }

            sceneNodeStack[_currentTabIndex.value].removeSubrange((index + 1)...)

            _willTransitionToSceneType.send(sceneType)

            presentingViewController.dismiss(
                animated: animated,
                completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.currentlyActiveTransition = nil
                        self._currentSceneType.value = type(of: self.currentSceneNode.scene)

                        self.sceneTransitionQueue.resume()

                        completion(true)
                    }
                })

            return true
        }

        return false
    }

    // MARK: - Current scene for internal use

    public private(set) lazy var willTransitionToSceneType: O<UISceneBase.Type> = _willTransitionToSceneType.asObservable()
    private let _willTransitionToSceneType = S<UISceneBase.Type>()

    public private(set) lazy var currentSceneType = P(_currentSceneType.distinctUntilChanged({ $0 == $1 }))  // safe here to use a property rooted in optional
    private let _currentSceneType = V<UISceneBase.Type?>(nil)

    // MARK: - Internal UI management for implicit UI events

    // Mainly called by `UIEmbeddingNavigationController` after the user taps a system Back button.
    public func _popSceneIfNeeded(ifContainsNavigationItem navigationItem: UINavigationItem) {
        enqueueTransitionAsync { [weak self] in
            guard let self = self else { return }

            let currentViewController = self.currentSceneNode.viewController
            if currentViewController.navigationItem === navigationItem {
                self.popSceneNode()

                let sceneType = type(of: self.currentSceneNode.scene)
                self._willTransitionToSceneType.send(sceneType)
                self._currentSceneType.value = sceneType
            }
        }
    }

    // Mainly called before presenting a third-party view controller by means of a third-party framework.
    public func _suspendTransitionQueue() {
        DispatchQueue.syncSafeOnMain {
            sceneTransitionQueue.suspend()
        }
    }

    // Mainly called after dismissing a third-party view controller by means of a third-party framework.
    public func _resumeTransitionQueue() {
        DispatchQueue.syncSafeOnMain {
            if sceneTransitionQueue.suspendCount > 0 {
                sceneTransitionQueue.resume()
            }
        }
    }

    // MARK: - Private

    private func enqueueTransitionSync(_ closure: VoidClosure) {
        sceneTransitionQueue.sync {
            DispatchQueue.syncSafeOnMain {
                closure()
            }
        }
    }

    private func enqueueTransitionAsync(_ closure: @escaping VoidClosure) {
        sceneTransitionQueue.async {
            DispatchQueue.syncSafeOnMain {
                closure()
            }
        }
    }

    private enum SceneNodeTransitionType {
        case root
        case next
        case up
    }

    private struct SceneNode {

        let transitionType: SceneNodeTransitionType
        let scene: UISceneBase
        let viewController: UIViewController
        let transitionStyle: UISceneTransitionStyle?
        let cachedTransition: UISceneTransition?

        init(transitionType: SceneNodeTransitionType, scene: UISceneBase, viewController: UIViewController, transitionStyle: UISceneTransitionStyle?) {
            self.transitionType = transitionType
            self.scene = scene
            self.viewController = viewController
            self.transitionStyle = transitionStyle
            self.cachedTransition = transitionStyle?.transition
        }

    }

    private func makeNextTransition(
        navigationController: UINavigationController, viewController: UIViewController, toScenes: [UISceneBase], transition: UISceneTransition?,
        completion: VoidClosure?) {

        assert(Thread.isMainThread)

        currentlyActiveTransition = transition
        navigationController.delegate = currentlyActiveTransition

        UIRootContainer.shared.disableUserInteraction()

        O.combineLatest(toScenes.map({ $0.sceneIsInitialized }))
            .observeOn(MainScheduler.instance)
            .filter { $0.allSatisfy({ $0 }) }
            .take(1)
            .subscribeOnNext { [weak self] _ in
                navigationController.pushViewController(viewController, animated: true, completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        UIRootContainer.shared.enableUserInteraction()

                        self?.currentlyActiveTransition = nil

                        completion?()
                    }
                })
            }
            .disposed(by: disposeBag)
    }

    private func makeUpTransition(
        viewController: UIViewController, fromScene: UISceneBase, toScenes: [UISceneBase], transition: UISceneTransition?,
        completion: VoidClosure?) {

        assert(Thread.isMainThread)

        currentlyActiveTransition = transition
        viewController.transitioningDelegate = currentlyActiveTransition

        // The value for `modalPresentationStyle` is `.custom` only for transitions with a presentation controller.
        if transition?.presentationControllerType == nil {
            viewController.modalPresentationStyle = .fullScreen
        } else {
            viewController.modalPresentationStyle = .custom
        }

        UIRootContainer.shared.disableUserInteraction()

        O.combineLatest(toScenes.map({ $0.sceneIsInitialized }))
            .observeOn(MainScheduler.instance)
            .filter { $0.allSatisfy({ $0 }) }
            .take(1)
            .subscribeOnNext { [weak self] _ in
                fromScene.viewController.present(viewController, animated: true, completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        UIRootContainer.shared.enableUserInteraction()

                        self?.currentlyActiveTransition = nil

                        completion?()
                    }
                })
            }
            .disposed(by: disposeBag)
    }

    private static func embedInNavigationControllerIfNeeded(_ viewController: UIViewController) -> UIViewController {
        assert(Thread.isMainThread)

        if !(viewController is UINavigationController) &&
           !(viewController is UITabBarController) &&
           !(viewController is UISplitViewController) {

            // Embed into a UINavigationController.
            return UIEmbeddingNavigationController(rootViewController: viewController)
        } else {
            // Use as is.
            return viewController
        }
    }

    private var currentSceneNode: SceneNode {
        assert(Thread.isMainThread)
        return sceneNodeStack[_currentTabIndex.value].last!
    }

    private var underlyingSceneNode: SceneNode? {
        assert(Thread.isMainThread)
        return sceneNodeStack[_currentTabIndex.value][safe: sceneNodeStack[_currentTabIndex.value].lastIndex - 1]
    }

    private func pushSceneNode(_ sceneNode: SceneNode) {
        assert(Thread.isMainThread)
        return sceneNodeStack[_currentTabIndex.value].append(sceneNode)
    }

    private func popSceneNode() {
        assert(Thread.isMainThread)
        sceneNodeStack[_currentTabIndex.value].removeLast()
    }

    private var sceneNodeCount: Int {
        assert(Thread.isMainThread)
        return sceneNodeStack[_currentTabIndex.value].count
    }

    private var backSceneNode: SceneNode {
        assert(Thread.isMainThread)

        let lastIndex = sceneNodeStack[_currentTabIndex.value].lastIndex
        return sceneNodeStack[_currentTabIndex.value][lastIndex - 1]
    }

}
