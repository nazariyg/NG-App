## NG App

This repository contains only my own code that I've been writing since 2018, first in Swift 4.2 and then in Swift 5. It reflects my vision of an iOS app that is based in high code quality, robustness, modularity, reusability, performance, and testability.

The app is taking full advantage of functional reactive programming powered by RxSwift and is using an FRP-based variant of the VIPER architecture. In the app's foundation there are three modules: **Cornerstones** framework, **Core** framework, and **UICore** framework.

  * **Cornerstones** provides additional functionality for the Swift language, Swift types such as strings and collections, concurrency, system permissions, caching, basic UIKit classes, and Core Animation. It also defines basic entities for networking and provides a service locator to support tests.
  * **Core** stands at a higher level and provides components and services for the app's internal infrastructure, which includes configuration, FRP types, persistent local storage, error handling, and networking.
  * **UICore** contains the app's library of consistently styled and reusable UI elements.
