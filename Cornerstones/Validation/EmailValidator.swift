// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct EmailValidator: Validator {

    public enum Error: Swift.Error {
        case invalidSyntax
        case paddingWhitespace
    }

    private struct Rule {
        static let regexPattern = "^[A-Z0-9a-z._%+-]+(?<!@)@[A-Za-z0-9.-]+(?<!\\.)\\.[A-Za-z]{2,64}$"
    }

    public let email: String

    public init(_ email: String) {
        self.email = email
    }

    public func validate() -> ValidationResult<Error> {
        if email.trimmed() != email {
            return .invalid(.paddingWhitespace)
        }
        if NSPredicate(format: "SELF MATCHES %@", Rule.regexPattern).evaluate(with: email) {
            return .valid
        } else {
            return .invalid(.invalidSyntax)
        }
    }

}
