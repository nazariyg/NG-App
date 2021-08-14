// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift

public struct UIState {

    /// Skipping repeats.
    public static private(set) var rootContainerDidAppear = P(setRootContainerDidAppear.distinctUntilChanged())
    public static let setRootContainerDidAppear = V<Bool>(false)

}
