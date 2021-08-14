// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIView {

    var isFirstResponder: Observable<Bool> {
        return DispatchQueue.syncSafeOnMain {
            return
                Observable.merge(
                    methodInvoked(#selector(UIView.becomeFirstResponder)),
                    methodInvoked(#selector(UIView.resignFirstResponder))
                )
                .map { [weak view = self.base] _ -> Bool in
                    view?.isFirstResponder ?? false
                }
                .startWith(base.isFirstResponder)
                .distinctUntilChanged()
        }
    }

}
