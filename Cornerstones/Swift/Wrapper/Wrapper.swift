// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

public final class ValueWrapper<Type> {

    public let value: Type

    public init(_ value: Type) {
        self.value = value
    }

}

public final class MutableValueWrapper<Type> {

    public var value: Type

    public init(_ value: Type) {
        self.value = value
    }

}

public final class AnyWrapper {

    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

}

public final class MutableAnyWrapper {

    public var value: Any

    public init(_ value: Any) {
        self.value = value
    }

}
