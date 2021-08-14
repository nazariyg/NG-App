// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIAlertController {

    static func showOkAlertOnTop(withTitle title: String?, message: String?) {
        guard let presentingViewController = UIViewController.topViewController else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)

        presentingViewController.present(alert, animated: true, completion: nil)
    }

}
