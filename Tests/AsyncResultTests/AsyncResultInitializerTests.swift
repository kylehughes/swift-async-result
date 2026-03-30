//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Initializers")
struct AsyncResultInitializerTests {
    @Test("Async catching captures a thrown error as failure")
    func asyncCatchingFailure() async {
        let asyncResult = await AsyncResult<Int, any Error>(
            catching: { () async throws -> Int in throw TestError.first }
        )
        #expect(asyncResult.failure is TestError)
    }

    @Test("Async catching captures a returned value as success")
    func asyncCatchingSuccess() async {
        let asyncResult = await AsyncResult<Int, any Error>(
            catching: { () async throws -> Int in 42 }
        )
        #expect(asyncResult.success == 42)
    }

    @Test("Async catching with mapError maps a thrown error")
    func asyncCatchingWithMapErrorFailure() async {
        let asyncResult = await AsyncResult<Int, TestError>(
            catching: { () async throws -> Int in throw TestError.second },
            mapError: { _ in .first }
        )
        #expect(asyncResult.failure == .first)
    }

    @Test("Async catching with mapError captures success")
    func asyncCatchingWithMapErrorSuccess() async {
        let asyncResult = await AsyncResult<Int, TestError>(
            catching: { () async throws -> Int in 42 },
            mapError: { _ in .first }
        )
        #expect(asyncResult.success == 42)
    }

    @Test("Async typed catching captures a typed error as failure")
    func asyncTypedCatchingFailure() async {
        let asyncResult = await AsyncResult<Int, TestError>(
            catching: { () async throws(TestError) -> Int in
                throw TestError.first
            }
        )
        #expect(asyncResult.failure == .first)
    }

    @Test("Async typed catching captures a returned value as success")
    func asyncTypedCatchingSuccess() async {
        let asyncResult = await AsyncResult<Int, TestError>(
            catching: { () async throws(TestError) -> Int in
                42
            }
        )
        #expect(asyncResult.success == 42)
    }

    @Test("Initializing with a failure produces a completed failure")
    func initFailure() {
        let asyncResult = AsyncResult<Int, TestError>(failure: .first)
        #expect(asyncResult == .completed(.failure(.first)))
    }

    @Test("Initializing from a Result wraps it in completed")
    func initFromResult() {
        let result: Result<Int, TestError> = .success(42)
        let asyncResult = AsyncResult<Int, TestError>(result)
        #expect(asyncResult == .completed(.success(42)))
    }

    @Test("Initializing with a success produces a completed success")
    func initSuccess() {
        let asyncResult = AsyncResult<Int, TestError>(success: 42)
        #expect(asyncResult == .completed(.success(42)))
    }

    @Test("Catching captures a thrown error as failure")
    func syncCatchingFailure() {
        let asyncResult = AsyncResult<Int, any Error> {
            throw TestError.first
        }
        #expect(asyncResult.failure is TestError)
    }

    @Test("Catching captures a returned value as success")
    func syncCatchingSuccess() {
        let asyncResult = AsyncResult<Int, any Error> {
            42
        }
        #expect(asyncResult.success == 42)
    }

    @Test("Catching with mapError maps a thrown error")
    func syncCatchingWithMapErrorFailure() {
        let asyncResult = AsyncResult<Int, TestError>(
            catching: { throw TestError.second },
            mapError: { _ in .first }
        )
        #expect(asyncResult.failure == .first)
    }

    @Test("Catching with mapError captures success")
    func syncCatchingWithMapErrorSuccess() {
        let asyncResult = AsyncResult<Int, TestError>(
            catching: { 42 },
            mapError: { _ in .first }
        )
        #expect(asyncResult.success == 42)
    }

    @Test("Typed catching captures a typed error as failure")
    func syncTypedCatchingFailure() {
        let asyncResult = AsyncResult<Int, TestError>(
            catching: { () throws(TestError) -> Int in
                throw TestError.first
            }
        )
        #expect(asyncResult.failure == .first)
    }

    @Test("Typed catching captures a returned value as success")
    func syncTypedCatchingSuccess() {
        let asyncResult = AsyncResult<Int, TestError>(
            catching: { () throws(TestError) -> Int in
                42
            }
        )
        #expect(asyncResult.success == 42)
    }
}
