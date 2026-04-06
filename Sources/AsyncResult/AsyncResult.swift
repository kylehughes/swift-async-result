//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

/// The result of an asynchronous operation that may still be in progress.
public enum AsyncResult<Success, Failure> where Failure: Error {
    /// The operation completed with the given result.
    case completed(Result<Success, Failure>)

    /// The operation is in progress.
    case inProgress

    /// Creates a completed asynchronous result from the given result.
    ///
    /// - Parameter result: The result of the operation.
    @inlinable
    public init(_ result: Result<Success, Failure>) {
        self = .completed(result)
    }

    /// Creates a completed asynchronous result by evaluating a throwing closure.
    ///
    /// The returned value becomes the success; any thrown error becomes the failure.
    ///
    /// - Parameter body: A closure that returns `Success` or throws `Failure`.
    @inlinable
    public init(catching body: () throws(Failure) -> Success) {
        do {
            self = try .completed(.success(body()))
        } catch {
            self = .completed(.failure(error))
        }
    }

    /// Creates a completed asynchronous result by evaluating a throwing closure.
    ///
    /// The returned value becomes the success; any thrown error becomes the failure.
    ///
    /// - Parameter body: A throwing closure that returns `Success`.
    @inlinable
    public init(catching body: () throws -> Success) where Failure == any Error {
        do {
            self = try .completed(.success(body()))
        } catch {
            self = .completed(.failure(error))
        }
    }

    /// Creates a completed asynchronous result by evaluating a throwing closure, mapping any thrown error.
    ///
    /// - Parameter body: A throwing closure that returns `Success`.
    /// - Parameter mapError: A closure that converts the thrown error into `Failure`.
    @inlinable
    public init(
        catching body: () throws -> Success,
        mapError: (any Error) -> Failure
    ) {
        do {
            self = try .completed(.success(body()))
        } catch {
            self = .completed(.failure(mapError(error)))
        }
    }

    /// Creates a completed asynchronous result by evaluating an asynchronous throwing closure.
    ///
    /// The returned value becomes the success; any thrown error becomes the failure.
    ///
    /// - Parameter body: An asynchronous closure that returns `Success` or throws `Failure`.
    @inlinable
    public init(catching body: () async throws(Failure) -> Success) async {
        do {
            self = try await .completed(.success(body()))
        } catch {
            self = .completed(.failure(error))
        }
    }

    /// Creates a completed asynchronous result by evaluating an asynchronous throwing closure.
    ///
    /// The returned value becomes the success; any thrown error becomes the failure.
    ///
    /// - Parameter body: An asynchronous throwing closure that returns `Success`.
    @inlinable
    public init(catching body: () async throws -> Success) async where Failure == any Error {
        do {
            self = try await .completed(.success(body()))
        } catch {
            self = .completed(.failure(error))
        }
    }

    /// Creates a completed asynchronous result by evaluating an asynchronous throwing closure, mapping any thrown
    /// error.
    ///
    /// - Parameter body: An asynchronous throwing closure that returns `Success`.
    /// - Parameter mapError: A closure that converts the thrown error into `Failure`.
    @inlinable
    public init(
        catching body: () async throws -> Success,
        mapError: (any Error) -> Failure
    ) async {
        do {
            self = try await .completed(.success(body()))
        } catch {
            self = .completed(.failure(mapError(error)))
        }
    }

    /// Creates a completed asynchronous result with the given error.
    ///
    /// - Parameter error: The failure value.
    @inlinable
    public init(failure error: Failure) {
        self = .completed(.failure(error))
    }

    /// Creates a completed asynchronous result from an optional value, using the given error if `nil`.
    ///
    /// - Parameter value: An optional value to wrap.
    /// - Parameter error: The error to use if `value` is `nil`, evaluated lazily.
    @inlinable
    public init(optional value: Success?, or error: @autoclosure () -> Failure) {
        if let value {
            self = .completed(.success(value))
        } else {
            self = .completed(.failure(error()))
        }
    }

    /// Creates a completed asynchronous result with the given value.
    ///
    /// - Parameter value: The success value.
    @inlinable
    public init(success value: Success) {
        self = .completed(.success(value))
    }

    /// The failure value, or `nil` if the operation succeeded or is in progress.
    @inlinable
    public var failure: Failure? {
        switch self {
        case let .completed(.failure(error)): error
        case .completed(.success), .inProgress: nil
        }
    }

    /// Whether the operation is completed.
    @inlinable
    public var isCompleted: Bool {
        switch self {
        case .completed: true
        case .inProgress: false
        }
    }

    /// Whether the operation completed with a failure.
    @inlinable
    public var isFailure: Bool {
        switch self {
        case .completed(.failure): true
        case .completed(.success), .inProgress: false
        }
    }

    /// Whether the operation is in progress.
    @inlinable
    public var isInProgress: Bool {
        switch self {
        case .completed: false
        case .inProgress: true
        }
    }

    /// Whether the operation completed successfully.
    @inlinable
    public var isSuccess: Bool {
        switch self {
        case .completed(.success): true
        case .completed(.failure), .inProgress: false
        }
    }

    /// The underlying result, or `nil` if the operation is in progress.
    @inlinable
    public var result: Result<Success, Failure>? {
        switch self {
        case let .completed(result): result
        case .inProgress: nil
        }
    }

    /// The success value, or `nil` if the operation failed or is in progress.
    @inlinable
    public var success: Success? {
        switch self {
        case let .completed(.success(value)): value
        case .completed(.failure), .inProgress: nil
        }
    }

    /// Returns a single asynchronous result combining a sequence of results into an array of success values.
    ///
    /// Priority is failure > in-progress > success: if any result is a failure, the first failure is returned. If any
    /// result is in progress and none have failed, the combined result is in progress. Otherwise, all success values
    /// are collected into an array.
    ///
    /// - Parameter results: A sequence of asynchronous results to combine.
    /// - Returns: A single asynchronous result containing an array of all success values, the first failure, or an
    ///   in-progress state.
    @inlinable
    public static func collect(
        _ results: some Sequence<AsyncResult<Success, Failure>>
    ) -> AsyncResult<[Success], Failure> {
        var values: [Success] = []
        var hasInProgress = false
        for result in results {
            switch result {
            case let .completed(.failure(error)):
                return .completed(.failure(error))
            case let .completed(.success(value)):
                values.append(value)
            case .inProgress:
                hasInProgress = true
            }
        }
        if hasInProgress {
            return .inProgress
        }
        return .completed(.success(values))
    }

    /// Returns a new asynchronous result, mapping any success value using the given transformation that returns an
    /// asynchronous result.
    ///
    /// - Parameter transform: A closure that takes the success value and returns a new asynchronous result.
    /// - Returns: The result of `transform` if this instance represents a success, or the existing failure or
    ///   in-progress state.
    @inlinable
    public func flatMap<NewSuccess>(
        _ transform: (Success) -> AsyncResult<NewSuccess, Failure>
    ) -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): transform(value)
            case let .failure(error): .completed(.failure(error))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result, mapping any success value using the given asynchronous transformation that
    /// returns an asynchronous result.
    ///
    /// - Parameter transform: An asynchronous closure that takes the success value and returns a new asynchronous
    ///   result.
    /// - Returns: The result of `transform` if this instance represents a success, or the existing failure or
    ///   in-progress state.
    @inlinable
    public func flatMap<NewSuccess>(
        _ transform: (Success) async -> AsyncResult<NewSuccess, Failure>
    ) async -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): await transform(value)
            case let .failure(error): .completed(.failure(error))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result, mapping any failure value using the given transformation that returns an
    /// asynchronous result.
    ///
    /// - Parameter transform: A closure that takes the failure value and returns a new asynchronous result.
    /// - Returns: The result of `transform` if this instance represents a failure, or the existing success or
    ///   in-progress state.
    @inlinable
    public func flatMapError<NewFailure>(
        _ transform: (Failure) -> AsyncResult<Success, NewFailure>
    ) -> AsyncResult<Success, NewFailure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(value))
            case let .failure(error): transform(error)
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result, mapping any failure value using the given asynchronous transformation that
    /// returns an asynchronous result.
    ///
    /// - Parameter transform: An asynchronous closure that takes the failure value and returns a new asynchronous
    ///   result.
    /// - Returns: The result of `transform` if this instance represents a failure, or the existing success or
    ///   in-progress state.
    @inlinable
    public func flatMapError<NewFailure>(
        _ transform: (Failure) async -> AsyncResult<Success, NewFailure>
    ) async -> AsyncResult<Success, NewFailure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(value))
            case let .failure(error): await transform(error)
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms the success value.
    /// - Returns: A new asynchronous result with the transformed success value, or the existing failure or in-progress
    ///   state.
    @inlinable
    public func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
    ) -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case .completed(let result): .completed(result.map(transform))
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with both the success and failure values transformed.
    ///
    /// This is useful at module boundaries where both types need to change in one pass.
    ///
    /// - Parameter success: A closure that transforms the success value.
    /// - Parameter failure: A closure that transforms the failure value.
    /// - Returns: A new asynchronous result with both types transformed.
    @inlinable
    public func map<NewSuccess, NewFailure>(
        success transformSuccess: (Success) -> NewSuccess,
        failure transformFailure: (Failure) -> NewFailure
    ) -> AsyncResult<NewSuccess, NewFailure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(transformSuccess(value)))
            case let .failure(error): .completed(.failure(transformFailure(error)))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by the given asynchronous closure.
    ///
    /// - Parameter transform: An asynchronous closure that transforms the success value.
    /// - Returns: A new asynchronous result with the transformed success value, or the existing failure or in-progress
    ///   state.
    @inlinable
    public func map<NewSuccess>(
        _ transform: (Success) async -> NewSuccess
    ) async -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(await transform(value)))
            case let .failure(error): .completed(.failure(error))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with both the success and failure values transformed by asynchronous
    /// closures.
    ///
    /// - Parameter success: An asynchronous closure that transforms the success value.
    /// - Parameter failure: An asynchronous closure that transforms the failure value.
    /// - Returns: A new asynchronous result with both types transformed.
    @inlinable
    public func map<NewSuccess, NewFailure>(
        success transformSuccess: (Success) async -> NewSuccess,
        failure transformFailure: (Failure) async -> NewFailure
    ) async -> AsyncResult<NewSuccess, NewFailure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(await transformSuccess(value)))
            case let .failure(error): .completed(.failure(await transformFailure(error)))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with the failure value transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms the failure value.
    /// - Returns: A new asynchronous result with the transformed failure value, or the existing success or in-progress
    ///   state.
    @inlinable
    public func mapError<NewFailure>(
        _ transform: (Failure) -> NewFailure
    ) -> AsyncResult<Success, NewFailure> {
        switch self {
        case let .completed(result): .completed(result.mapError(transform))
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with the failure value transformed by the given asynchronous closure.
    ///
    /// - Parameter transform: An asynchronous closure that transforms the failure value.
    /// - Returns: A new asynchronous result with the transformed failure value, or the existing success or in-progress
    ///   state.
    @inlinable
    public func mapError<NewFailure>(
        _ transform: (Failure) async -> NewFailure
    ) async -> AsyncResult<Success, NewFailure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(value))
            case let .failure(error): .completed(.failure(await transform(error)))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result combining this result with another using the given closure.
    ///
    /// Priority is failure > in-progress > success: if either result is a failure, the combined result contains that
    /// failure. If either is in progress and neither has failed, the combined result is in progress. Otherwise, both
    /// success values are passed to `transform`.
    ///
    /// - Parameter other: Another asynchronous result to combine with this one.
    /// - Parameter transform: A closure that combines the success values from both results.
    /// - Returns: A new asynchronous result containing the combined success, the first failure, or an in-progress
    ///   state.
    @inlinable
    public func merge<OtherSuccess, NewSuccess>(
        with other: AsyncResult<OtherSuccess, Failure>,
        using transform: (Success, OtherSuccess) -> NewSuccess
    ) -> AsyncResult<NewSuccess, Failure> {
        switch (self, other) {
        case let (.completed(.failure(error)), _):
            .completed(.failure(error))
        case let (_, .completed(.failure(error))):
            .completed(.failure(error))
        case (.inProgress, _), (_, .inProgress):
            .inProgress
        case let (.completed(.success(value)), .completed(.success(otherValue))):
            .completed(.success(transform(value, otherValue)))
        }
    }

    /// Returns a new infallible asynchronous result by transforming any failure into a success.
    ///
    /// The return type `AsyncResult<Success, Never>` proves at compile time that recovery has occurred and the result
    /// can no longer fail.
    ///
    /// - Parameter transform: A closure that converts a failure value into a success value.
    /// - Returns: An infallible asynchronous result.
    @inlinable
    public func recover(
        _ transform: (Failure) -> Success
    ) -> AsyncResult<Success, Never> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(value))
            case let .failure(error): .completed(.success(transform(error)))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new infallible asynchronous result by asynchronously transforming any failure into a success.
    ///
    /// The return type `AsyncResult<Success, Never>` proves at compile time that recovery has occurred and the result
    /// can no longer fail.
    ///
    /// - Parameter transform: An asynchronous closure that converts a failure value into a success value.
    /// - Returns: An infallible asynchronous result.
    @inlinable
    public func recover(
        _ transform: (Failure) async -> Success
    ) async -> AsyncResult<Success, Never> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value): .completed(.success(value))
            case let .failure(error): .completed(.success(await transform(error)))
            }
        case .inProgress: .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by a throwing closure.
    ///
    /// If the closure throws, the error is captured as a failure. This is useful for transformations that can fail,
    /// such as decoding, validation, or normalization.
    ///
    /// - Parameter transform: A closure that transforms the success value or throws `Failure`.
    /// - Returns: A new asynchronous result with the transformed success value, or the thrown error as a failure.
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) throws(Failure) -> NewSuccess
    ) -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value):
                do {
                    return .completed(.success(try transform(value)))
                } catch {
                    return .completed(.failure(error))
                }
            case let .failure(error): return .completed(.failure(error))
            }
        case .inProgress: return .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by a throwing closure.
    ///
    /// - Parameter transform: A throwing closure that transforms the success value.
    /// - Returns: A new asynchronous result with the transformed success value, or the thrown error as a failure.
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> AsyncResult<NewSuccess, Failure> where Failure == any Error {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value):
                do {
                    return .completed(.success(try transform(value)))
                } catch {
                    return .completed(.failure(error))
                }
            case let .failure(error): return .completed(.failure(error))
            }
        case .inProgress: return .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by a throwing closure, mapping any thrown
    /// error.
    ///
    /// - Parameter transform: A throwing closure that transforms the success value.
    /// - Parameter mapError: A closure that converts the thrown error into `Failure`.
    /// - Returns: A new asynchronous result with the transformed success value, or the mapped error as a failure.
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess,
        mapError: (any Error) -> Failure
    ) -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value):
                do {
                    return .completed(.success(try transform(value)))
                } catch {
                    return .completed(.failure(mapError(error)))
                }
            case let .failure(error): return .completed(.failure(error))
            }
        case .inProgress: return .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by an asynchronous throwing closure.
    ///
    /// - Parameter transform: An asynchronous closure that transforms the success value or throws `Failure`.
    /// - Returns: A new asynchronous result with the transformed success value, or the thrown error as a failure.
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) async throws(Failure) -> NewSuccess
    ) async -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value):
                do {
                    return .completed(.success(try await transform(value)))
                } catch {
                    return .completed(.failure(error))
                }
            case let .failure(error): return .completed(.failure(error))
            }
        case .inProgress: return .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by an asynchronous throwing closure.
    ///
    /// - Parameter transform: An asynchronous throwing closure that transforms the success value.
    /// - Returns: A new asynchronous result with the transformed success value, or the thrown error as a failure.
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess
    ) async -> AsyncResult<NewSuccess, Failure> where Failure == any Error {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value):
                do {
                    return .completed(.success(try await transform(value)))
                } catch {
                    return .completed(.failure(error))
                }
            case let .failure(error): return .completed(.failure(error))
            }
        case .inProgress: return .inProgress
        }
    }

    /// Returns a new asynchronous result with the success value transformed by an asynchronous throwing closure,
    /// mapping any thrown error.
    ///
    /// - Parameter transform: An asynchronous throwing closure that transforms the success value.
    /// - Parameter mapError: A closure that converts the thrown error into `Failure`.
    /// - Returns: A new asynchronous result with the transformed success value, or the mapped error as a failure.
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess,
        mapError: (any Error) -> Failure
    ) async -> AsyncResult<NewSuccess, Failure> {
        switch self {
        case let .completed(result):
            switch result {
            case let .success(value):
                do {
                    return .completed(.success(try await transform(value)))
                } catch {
                    return .completed(.failure(mapError(error)))
                }
            case let .failure(error): return .completed(.failure(error))
            }
        case .inProgress: return .inProgress
        }
    }

    /// Returns a new asynchronous result with the optional success value unwrapped, or a failure if `nil`.
    ///
    /// Transforms `AsyncResult<Wrapped?, Failure>` into `AsyncResult<Wrapped, Failure>`.
    ///
    /// - Parameter error: The error to use if the success value is `nil`, evaluated lazily.
    /// - Returns: An asynchronous result with a non-optional success type.
    @inlinable
    public func unwrap<Wrapped>(
        or error: @autoclosure () -> Failure
    ) -> AsyncResult<Wrapped, Failure> where Success == Wrapped? {
        flatMap { value in
            if let value {
                return .completed(.success(value))
            } else {
                return .completed(.failure(error()))
            }
        }
    }

    /// Returns a new asynchronous result combining this result with another into a tuple.
    ///
    /// Priority is failure > in-progress > success, matching ``merge(with:using:)``.
    ///
    /// - Parameter other: Another asynchronous result to combine with this one.
    /// - Returns: A new asynchronous result containing a tuple of both success values, the first failure, or an
    ///   in-progress state.
    @inlinable
    public func zip<OtherSuccess>(
        with other: AsyncResult<OtherSuccess, Failure>
    ) -> AsyncResult<(Success, OtherSuccess), Failure> {
        merge(with: other) { ($0, $1) }
    }
}

extension AsyncResult: CustomStringConvertible {
    /// A textual representation of this asynchronous result.
    @inlinable
    public var description: String {
        switch self {
        case let .completed(result): "AsyncResult.completed(\(result))"
        case .inProgress: "AsyncResult.inProgress"
        }
    }
}

extension AsyncResult: Equatable where Success: Equatable, Failure: Equatable {}

extension AsyncResult: Hashable where Success: Hashable, Failure: Hashable {}

extension AsyncResult: Sendable where Success: Sendable {}

extension AsyncResult where Failure == Never {
    /// Creates a completed infallible asynchronous result with the given value.
    ///
    /// - Parameter value: The success value.
    @inlinable
    public init(_ value: Success) {
        self = .completed(.success(value))
    }

    /// Returns this result with the failure type changed to the given type.
    ///
    /// Because `Failure` is `Never`, this operation is safe — no failure values exist to transform. This is useful
    /// for composing infallible results with fallible ones using ``zip(with:)`` or ``merge(with:using:)``.
    ///
    /// - Parameter type: The new failure type.
    /// - Returns: This result with the failure type changed.
    @inlinable
    public func setFailureType<NewFailure>(
        to type: NewFailure.Type
    ) -> AsyncResult<Success, NewFailure> {
        switch self {
        case let .completed(.success(value)): .completed(.success(value))
        case .inProgress: .inProgress
        }
    }

    /// The success value if completed, or `nil` if in progress.
    ///
    /// Unlike ``success``, which returns `nil` for both failure and in-progress states, this property returns `nil`
    /// only when the operation is in progress. The `Failure == Never` constraint guarantees that failure is impossible.
    @inlinable
    public var value: Success? {
        switch self {
        case let .completed(.success(value)): value
        case .inProgress: nil
        }
    }
}
