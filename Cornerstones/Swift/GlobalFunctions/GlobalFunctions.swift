// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

@inlinable
@discardableResult
public func with<Type>(_ subject: Type, _ closure: (Type) -> Void) -> Type {
    closure(subject)
    return subject
}

@inlinable
public func with<Type0, Type1>(_ subject0: Type0, _ subject1: Type1, _ closure: (Type0, Type1) -> Void) {
    closure(subject0, subject1)
}

@inlinable
@discardableResult
public func withOptional<Type>(_ subject: Type?, _ closure: (Type) -> Void) -> Type? {
    if let subject = subject {
        closure(subject)
    }
    return subject
}

@inlinable
public func withOptional<Type0, Type1>(_ subject0: Type0?, _ subject1: Type1?, _ closure: (Type0, Type1) -> Void) {
    if let subject0 = subject0, let subject1 = subject1 {
        closure(subject0, subject1)
    }
}

/// "TypeName"
@inlinable
public func stringType(_ some: Any) -> String {
    let string = (some is Any.Type) ? String(describing: some) : String(describing: type(of: some))
    return string
}

/// "Module.TypeName"
@inlinable
public func fullStringType(_ some: Any) -> String {
    let string = (some is Any.Type) ? String(reflecting: some) : String(reflecting: type(of: some))
    return string
}
