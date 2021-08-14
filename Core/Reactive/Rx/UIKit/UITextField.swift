// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import RxSwift
import RxCocoa

extension UITextField: BiBindable {

    public func biBind(to property: SettableBehaviorRelay<String>) -> Disposable {
        var disposable1: Disposable?
        var disposable2: Disposable?

        disposable1 =
            property.asObservable()
            .distinctUntilChanged()
            .map { value -> String? in Optional(value) }
            .do(onDispose: { disposable2?.dispose() })
            .bind(to: rx.text)

        disposable2 =
            rx.text.asObservable()
            .distinctUntilChanged()
            .do(onDispose: { disposable1?.dispose() })
            .subscribe(onNext: { property.value = $0 ?? "" })

        return CompositeDisposable(disposable1!, disposable2!)
    }

}
