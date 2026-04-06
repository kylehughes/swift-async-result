//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Non-Sendable closure capture")
struct AsyncResultNonSendableClosureTests {
    @Test("Async catching captures a value from a non-sendable box")
    func asyncCatching() async {
        let box = NonSendableBox(42)
        let result = await AsyncResult<Int, any Error>(
            catching: { () async throws -> Int in await forceAsync(box.value) }
        )
        #expect(result.success == 42)
    }

    @Test("Async catching with mapError captures values from non-sendable boxes")
    func asyncCatchingWithMapError() async {
        let box = NonSendableBox(42)
        let errorBox = NonSendableBox(TestError.first)
        let result = await AsyncResult<Int, TestError>(
            catching: { () async throws -> Int in await forceAsync(box.value) },
            mapError: { _ in errorBox.value }
        )
        #expect(result.success == 42)
    }

    @Test("Async typed catching captures a value from a non-sendable box")
    func asyncTypedCatching() async {
        let box = NonSendableBox(42)
        let result = await AsyncResult<Int, TestError>(
            catching: { () async throws(TestError) -> Int in await forceAsync(box.value) }
        )
        #expect(result.success == 42)
    }

    @Test("Async flat-mapping captures a value from a non-sendable box")
    func flatMap() async {
        let box = NonSendableBox(100)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.flatMap { value in
            await forceAsync(AsyncResult<Int, TestError>.completed(.success(value + box.value)))
        }
        #expect(result == .completed(.success(121)))
    }

    @Test("Async flat-map-error captures a value from a non-sendable box")
    func flatMapError() async {
        let box = NonSendableBox(99)
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = await sut.flatMapError { _ in
            await forceAsync(AsyncResult<Int, OtherError>.completed(.success(box.value)))
        }
        #expect(result == .completed(.success(99)))
    }

    @Test("Async mapping captures a value from a non-sendable box")
    func map() async {
        let box = NonSendableBox(100)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let mapped = await sut.map { value in await forceAsync(value + box.value) }
        #expect(mapped == .completed(.success(121)))
    }

    @Test("Async map-both captures values from non-sendable boxes")
    func mapBoth() async {
        let successBox = NonSendableBox(100)
        let failureBox = NonSendableBox(OtherError.mapped)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let mapped = await sut.map(
            success: { value in await forceAsync(value + successBox.value) },
            failure: { _ in await forceAsync(failureBox.value) }
        )
        #expect(mapped == .completed(.success(121)))
    }

    @Test("Async map-error captures a value from a non-sendable box")
    func mapError() async {
        let box = NonSendableBox(OtherError.mapped)
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let mapped = await sut.mapError { _ in await forceAsync(box.value) }
        #expect(mapped == .completed(.failure(.mapped)))
    }

    @Test("Async recovery captures a value from a non-sendable box")
    func recover() async {
        let box = NonSendableBox(99)
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let recovered = await sut.recover { _ in await forceAsync(box.value) }
        #expect(recovered == .completed(.success(99)))
    }

    @Test("Async typed tryMap captures a value from a non-sendable box")
    func tryMapTyped() async {
        let box = NonSendableBox(100)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap {
            (value: Int) async throws(TestError) -> Int in await forceAsync(value + box.value)
        }
        #expect(result == .completed(.success(121)))
    }

    @Test("Async untyped tryMap captures a value from a non-sendable box")
    func tryMapUntyped() async {
        let box = NonSendableBox(100)
        let sut = AsyncResult<Int, any Error>.completed(.success(21))
        let result = await sut.tryMap {
            (value: Int) async throws -> Int in await forceAsync(value + box.value)
        }
        #expect(result.success == 121)
    }

    @Test("Async tryMap with mapError captures values from non-sendable boxes")
    func tryMapWithMapError() async {
        let box = NonSendableBox(100)
        let errorBox = NonSendableBox(TestError.first)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap(
            { (value: Int) async throws -> Int in await forceAsync(value + box.value) },
            mapError: { _ in errorBox.value }
        )
        #expect(result == .completed(.success(121)))
    }
}
