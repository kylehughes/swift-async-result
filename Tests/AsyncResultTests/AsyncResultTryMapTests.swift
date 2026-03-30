//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("tryMap")
struct AsyncResultTryMapTests {
    @Test("Async tryMap with mapError captures a thrown error")
    func asyncMapErrorFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap(
            { (_: Int) async throws -> Int in throw TestError.second },
            mapError: { _ in .first }
        )
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Async tryMap with mapError preserves in-progress")
    func asyncMapErrorInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = await sut.tryMap(
            { (v: Int) async throws -> Int in await forceAsync(v * 2) },
            mapError: { _ in .first }
        )
        #expect(result == .inProgress)
    }

    @Test("Async tryMap with mapError propagates an existing failure")
    func asyncMapErrorPropagatesExistingFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.second))
        let result = await sut.tryMap(
            { (v: Int) async throws -> Int in await forceAsync(v * 2) },
            mapError: { _ in .first }
        )
        #expect(result == .completed(.failure(.second)))
    }

    @Test("Async tryMap with mapError transforms the value")
    func asyncMapErrorSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap(
            { (v: Int) async throws -> Int in await forceAsync(v * 2) },
            mapError: { _ in .first }
        )
        #expect(result == .completed(.success(42)))
    }

    @Test("Async typed tryMap captures a thrown error as failure")
    func asyncTypedThrowsFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap {
            (_: Int) async throws(TestError) -> Int in throw .first
        }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Async typed tryMap preserves in-progress")
    func asyncTypedThrowsInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = await sut.tryMap {
            (v: Int) async throws(TestError) -> Int in await forceAsync(v * 2)
        }
        #expect(result == .inProgress)
    }

    @Test("Async typed tryMap propagates an existing failure")
    func asyncTypedThrowsPropagatesExistingFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.second))
        let result = await sut.tryMap {
            (v: Int) async throws(TestError) -> Int in await forceAsync(v * 2)
        }
        #expect(result == .completed(.failure(.second)))
    }

    @Test("Async typed tryMap transforms the value")
    func asyncTypedThrowsSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap {
            (v: Int) async throws(TestError) -> Int in await forceAsync(v * 2)
        }
        #expect(result == .completed(.success(42)))
    }

    @Test("Async untyped tryMap captures a thrown error as failure")
    func asyncUntypedThrowsFailure() async {
        let sut = AsyncResult<Int, any Error>.completed(.success(21))
        let result = await sut.tryMap {
            (_: Int) async throws -> Int in throw TestError.first
        }
        #expect(result.failure is TestError)
    }

    @Test("Async untyped tryMap preserves in-progress")
    func asyncUntypedThrowsInProgress() async {
        let sut = AsyncResult<Int, any Error>.inProgress
        let result = await sut.tryMap {
            (v: Int) async throws -> Int in await forceAsync(v * 2)
        }
        #expect(result.isInProgress)
    }

    @Test("Async untyped tryMap propagates an existing failure")
    func asyncUntypedThrowsPropagatesExistingFailure() async {
        let sut = AsyncResult<Int, any Error>.completed(.failure(TestError.first))
        let result = await sut.tryMap {
            (v: Int) async throws -> Int in await forceAsync(v * 2)
        }
        #expect(result.failure is TestError)
    }

    @Test("Async untyped tryMap transforms the value")
    func asyncUntypedThrowsSuccess() async {
        let sut = AsyncResult<Int, any Error>.completed(.success(21))
        let result = await sut.tryMap {
            (v: Int) async throws -> Int in await forceAsync(v * 2)
        }
        #expect(result.success == 42)
    }

    @Test("tryMap with mapError captures a thrown error")
    func mapErrorFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.tryMap(
            { (_: Int) throws -> Int in throw TestError.second },
            mapError: { _ in .first }
        )
        #expect(result == .completed(.failure(.first)))
    }

    @Test("tryMap with mapError preserves in-progress")
    func mapErrorInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = sut.tryMap({ $0 * 2 }, mapError: { _ in .first })
        #expect(result == .inProgress)
    }

    @Test("tryMap with mapError propagates an existing failure")
    func mapErrorPropagatesExistingFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.second))
        let result = sut.tryMap({ $0 * 2 }, mapError: { _ in .first })
        #expect(result == .completed(.failure(.second)))
    }

    @Test("tryMap with mapError transforms the value")
    func mapErrorSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.tryMap({ $0 * 2 }, mapError: { _ in .first })
        #expect(result == .completed(.success(42)))
    }

    @Test("Typed tryMap captures a thrown error as failure")
    func typedThrowsFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.tryMap { (_: Int) throws(TestError) -> Int in throw .first }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Typed tryMap preserves in-progress")
    func typedThrowsInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = sut.tryMap { (v: Int) throws(TestError) -> Int in v * 2 }
        #expect(result == .inProgress)
    }

    @Test("Typed tryMap propagates an existing failure")
    func typedThrowsPropagatesExistingFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.second))
        let result = sut.tryMap { (v: Int) throws(TestError) -> Int in v * 2 }
        #expect(result == .completed(.failure(.second)))
    }

    @Test("Typed tryMap transforms the value")
    func typedThrowsSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.tryMap { (v: Int) throws(TestError) -> Int in v * 2 }
        #expect(result == .completed(.success(42)))
    }

    @Test("Untyped tryMap captures a thrown error as failure")
    func untypedThrowsFailure() {
        let sut = AsyncResult<Int, any Error>.completed(.success(21))
        let result = sut.tryMap { (_: Int) throws -> Int in throw TestError.first }
        #expect(result.failure is TestError)
    }

    @Test("Untyped tryMap preserves in-progress")
    func untypedThrowsInProgress() {
        let sut = AsyncResult<Int, any Error>.inProgress
        let result = sut.tryMap { $0 * 2 }
        #expect(result.isInProgress)
    }

    @Test("Untyped tryMap propagates an existing failure")
    func untypedThrowsPropagatesExistingFailure() {
        let sut = AsyncResult<Int, any Error>.completed(.failure(TestError.first))
        let result = sut.tryMap { $0 * 2 }
        #expect(result.failure is TestError)
    }

    @Test("Untyped tryMap transforms the value")
    func untypedThrowsSuccess() {
        let sut = AsyncResult<Int, any Error>.completed(.success(21))
        let result = sut.tryMap { $0 * 2 }
        #expect(result.success == 42)
    }
}
