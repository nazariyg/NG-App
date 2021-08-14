// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift
import RxCocoa
import RxOptional
import RxSwiftExt
import RxGesture
import RxKeyboard

public typealias O = Observable                        // observable
public typealias Os = Single                           // single element observable
public typealias S = PublishRelay                      // emittable/observable stream
public typealias Se = PublishSubject                   // emittable/observable stream able to push errors
public typealias V = SettableBehaviorRelay             // variable, mutable property, cold signal
public typealias P = BehaviorRelayImmutabilityWrapper  // immutable property, cold signal
public typealias E = Event                             // event
