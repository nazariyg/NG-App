// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// The protocol to be adopted by any input-to-output mapper.
public protocol InputOutputMapper {
    associatedtype Input
    associatedtype Output
    func map(input: Input) -> Output?
}

private protocol NormalExecutionSharedInstanceRecordProtocol {
    var instantiationOrder: Int { get }
    func currentInstance() -> Any?
    func nullifyInstanceIfResettable()
    func resetInstanceIfResettable()
}

public final class InstanceService {

    public static let shared = InstanceService()

    private static var sharedInstanceNextInstantiationOrder = 0

    // MARK: - Nested types

    /// Represents the output instance produced from an input, along with an optional time delay.
    public struct OutputResult<Output> {
        public let output: Output
        public let delay: TimeInterval?
    }

    private var normalExecutionSharedInstanceRecords: [String: NormalExecutionSharedInstanceRecordProtocol] = [:]
    private let sharedInstancesAccessLock = VoidObject()
    private let instanceInjectionLock = VoidObject()

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Shared instance management for normal execution

    /// Registers a shared instance for normal execution or returns the already registered instance, if any.
    /// Called behind the scenes from `SharedInstance.shared` when a shared instance is requested.
    @discardableResult
    public func registerOrGetSharedInstanceForNormalExecution<SharedInstanceType: SharedInstance>(
        for sharedInstanceType: SharedInstanceType.Type, isResettable: Bool) -> SharedInstanceType.InstanceProtocol {

        return synchronized(sharedInstancesAccessLock) {
            let key = fullStringType(sharedInstanceType)

            if let instance = normalExecutionSharedInstanceRecords[key]?.currentInstance() as? SharedInstanceType.InstanceProtocol {
                return instance
            }

            // Instantiate and register.
            let instance = sharedInstanceType.defaultInstance()
            let record =
                NormalExecutionSharedInstanceRecord(
                    instantiationOrder: Self.sharedInstanceNextInstantiationOrder, sharedInstanceType: sharedInstanceType,
                    instance: instance, isResettable: isResettable)
            normalExecutionSharedInstanceRecords[key] = record

            Self.sharedInstanceNextInstantiationOrder += 1

            return instance
        }
    }

    /// Re-instantiates all registered shared instances. Useful for resetting the global state on events such as logging out.
    public func resetRegisteredSharedInstancesForNormalExecution() {
        synchronized(sharedInstancesAccessLock) {
            // First, nullify the registered instances in the order reverse to that in which they were registered.
            normalExecutionSharedInstanceRecords.values
                .sorted(by: { $0.instantiationOrder > $1.instantiationOrder })
                .forEach { $0.nullifyInstanceIfResettable() }

            // Then reset the instances in the order they were registered.
            normalExecutionSharedInstanceRecords.values
                .sorted(by: { $0.instantiationOrder < $1.instantiationOrder })
                .forEach { $0.resetInstanceIfResettable() }
        }
    }

    /// Removes all registered shared instances.
    public func unregisterAllSharedInstancesForNormalExecution() {
        synchronized(sharedInstancesAccessLock) {
            // Nullify the registered instances in the order reverse to that in which they were registered.
            normalExecutionSharedInstanceRecords.values
                .sorted(by: { $0.instantiationOrder > $1.instantiationOrder })
                .forEach { $0.nullifyInstanceIfResettable() }

            normalExecutionSharedInstanceRecords.removeAll()
            Self.sharedInstanceNextInstantiationOrder = 0
        }
    }

    // MARK: - Instance injection

    /// Sets a replacement instance to be used when constructing an instance conforming to a specific protocol.
    public func setInstance<InstanceProtocol>(for: InstanceProtocol.Type, instance: InstanceProtocol) {
        assert(TestingDetector.isTesting)
        synchronized(instanceInjectionLock) {
            let key = fullStringType(InstanceProtocol.self)
            storeStates[storeStates.lastIndex].stringTypesToInstances[key] = instance
        }
    }

    /// Dynamically selects the instance for a specific protocol from a mutable store or uses the provided default instance if no instance has been set
    /// for that protocol in the store. Called when accessing shared instances and by the rest of the code that supports this kind of dependency injection.
    public func instance<InstanceProtocol>(for: InstanceProtocol.Type, defaultInstance: @autoclosure () -> InstanceProtocol) -> InstanceProtocol {
        return synchronized(instanceInjectionLock) {
            let key = fullStringType(InstanceProtocol.self)
            let setInstance = storeStates[storeStates.lastIndex].stringTypesToInstances[key] as? InstanceProtocol
            return setInstance ?? defaultInstance()
        }
    }

    // MARK: - Input/output injection

    /// Registers an input-to-output mapper that takes in an input and optionally produces an output instance to be used as the substitute.
    /// If the mapper returns `nil`, no substitution happens and the code goes its usual course.
    public func registerInputOutputMapper<Mapper: InputOutputMapper>(mapper: Mapper, outputDelay: TimeInterval? = nil) {
        assert(TestingDetector.isTesting)
        synchronized(instanceInjectionLock) {
            let key = Self.keyForInputOutputTypes(inputType: Mapper.Input.self, outputType: Mapper.Output.self)
            let mapClosure: InstanceStore.MapperRecord.MapClosure = { input in
                let typedInput = input as! Mapper.Input
                let output = mapper.map(input: typedInput)
                return output
            }
            let mapperRecord = InstanceStore.MapperRecord(mapClosure: mapClosure, delay: outputDelay)
            storeStates[storeStates.lastIndex].stringTypesToInputOutputMappers[key] = mapperRecord
        }
    }

    /// Returns the replacement output instance for a given input, if any mappers are registered for the combination of the two types.
    /// Called e.g. when making HTTP requests to see if any HTTP response mappers have been registered.
    public func outputForInput<Input, Output>(_ input: Input, outputType: Output.Type = Output.self) -> OutputResult<Output>? {
        if TestingDetector.isNormalExecution {
            return nil
        }
        return synchronized(instanceInjectionLock) {
            let key = Self.keyForInputOutputTypes(inputType: Input.self, outputType: Output.self)
            if let mapperRecord = storeStates[storeStates.lastIndex].stringTypesToInputOutputMappers[key] {
                if let output = mapperRecord.mapClosure(input) {
                    let output = output as! Output
                    return OutputResult(output: output, delay: mapperRecord.delay)
                }
            }
            return nil
        }
    }

    // MARK: - State operations

    /// Pushes a copy of the instance store.
    public func pushInstanceInjectionState() {
        synchronized(instanceInjectionLock) {
            let stateCopy = storeStates.last!
            storeStates.append(stateCopy)
        }
    }

    /// Pops the last pushed copy of the instance store.
    public func popInstanceInjectionState() {
        synchronized(instanceInjectionLock) {
            assert(storeStates.count > 1)
            storeStates.removeLast()
        }
    }

    /// Resets the instance store.
    public func resetInstanceInjectionState() {
        synchronized(instanceInjectionLock) {
            storeStates = [InstanceStore()]
        }
    }

    // MARK: - Private

    private final class NormalExecutionSharedInstanceRecord<SharedInstanceType: SharedInstance>: NormalExecutionSharedInstanceRecordProtocol {

        let instantiationOrder: Int

        private let sharedInstanceType: SharedInstanceType.Type
        private var instance: SharedInstanceType.InstanceProtocol?
        private let isResettable: Bool

        init(
            instantiationOrder: Int, sharedInstanceType: SharedInstanceType.Type, instance: SharedInstanceType.InstanceProtocol?, isResettable: Bool) {

            self.instantiationOrder = instantiationOrder
            self.sharedInstanceType = sharedInstanceType
            self.instance = instance
            self.isResettable = isResettable
        }

        func currentInstance() -> Any? {
            return instance
        }

        func nullifyInstanceIfResettable() {
            if isResettable {
                instance = nil
            }
        }

        func resetInstanceIfResettable() {
            if isResettable {
                instance = sharedInstanceType.defaultInstance()
            }
        }

    }

    private struct InstanceStore {

        struct MapperRecord {
            typealias MapClosure = (Any) -> Any?
            let mapClosure: MapClosure
            let delay: TimeInterval?
        }

        var stringTypesToInstances: [String: Any] = [:]
        var stringTypesToInputOutputMappers: [String: MapperRecord] = [:]

    }

    private var storeStates: [InstanceStore] = [InstanceStore()]

    private static func keyForInputOutputTypes<Input, Output>(inputType: Input.Type, outputType: Output.Type) -> String {
        let key = "\(fullStringType(Input.self)) -> \(fullStringType(Output.self))"
        return key
    }

}
