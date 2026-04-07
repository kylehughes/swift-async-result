//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Main-actor-isolated closure capture")
@MainActor struct AsyncResultMainActorClosureTests {
    @Test("Async catching captures a value from a main-actor-isolated class")
    func asyncCatching() async {
        let counter = MainActorBox(42)
        let result = await AsyncResult<Int, any Error>(
            catching: { () async throws -> Int in await forceAsync(counter.value) }
        )
        #expect(result.success == 42)
    }

    @Test("Async catching with mapError captures main-actor-isolated state")
    func asyncCatchingWithMapError() async {
        let counter = MainActorBox(42)
        let errorBox = MainActorBox(TestError.first)
        let result = await AsyncResult<Int, TestError>(
            catching: { () async throws -> Int in await forceAsync(counter.value) },
            mapError: { _ in errorBox.value }
        )
        #expect(result.success == 42)
    }

    @Test("Async typed catching captures a value from a main-actor-isolated class")
    func asyncTypedCatching() async {
        let counter = MainActorBox(42)
        let result = await AsyncResult<Int, TestError>(
            catching: { () async throws(TestError) -> Int in await forceAsync(counter.value) }
        )
        #expect(result.success == 42)
    }

    @Test("Async flat-mapping captures a value from a main-actor-isolated class")
    func flatMap() async {
        let counter = MainActorBox(100)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.flatMap { value in
            await forceAsync(AsyncResult<Int, TestError>.completed(.success(value + counter.value)))
        }
        #expect(result == .completed(.success(121)))
    }

    @Test("Async flat-map-error captures a value from a main-actor-isolated class")
    func flatMapError() async {
        let counter = MainActorBox(99)
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = await sut.flatMapError { _ in
            await forceAsync(AsyncResult<Int, OtherError>.completed(.success(counter.value)))
        }
        #expect(result == .completed(.success(99)))
    }

    @Test("Async mapping captures a value from a main-actor-isolated class")
    func map() async {
        let counter = MainActorBox(100)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let mapped = await sut.map { value in await forceAsync(value + counter.value) }
        #expect(mapped == .completed(.success(121)))
    }

    @Test("Async map-both captures values from main-actor-isolated classes")
    func mapBoth() async {
        let successBox = MainActorBox(100)
        let failureBox = MainActorBox(OtherError.mapped)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let mapped = await sut.map(
            success: { value in await forceAsync(value + successBox.value) },
            failure: { _ in await forceAsync(failureBox.value) }
        )
        #expect(mapped == .completed(.success(121)))
    }

    @Test("Async map-error captures a value from a main-actor-isolated class")
    func mapError() async {
        let box = MainActorBox(OtherError.mapped)
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let mapped = await sut.mapError { _ in await forceAsync(box.value) }
        #expect(mapped == .completed(.failure(.mapped)))
    }

    @Test("Async recovery captures a value from a main-actor-isolated class")
    func recover() async {
        let counter = MainActorBox(99)
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let recovered = await sut.recover { _ in await forceAsync(counter.value) }
        #expect(recovered == .completed(.success(99)))
    }

    @Test("Async typed tryMap captures a value from a main-actor-isolated class")
    func tryMapTyped() async {
        let counter = MainActorBox(100)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap {
            (value: Int) async throws(TestError) -> Int in await forceAsync(value + counter.value)
        }
        #expect(result == .completed(.success(121)))
    }

    @Test("Async untyped tryMap captures a value from a main-actor-isolated class")
    func tryMapUntyped() async {
        let counter = MainActorBox(100)
        let sut = AsyncResult<Int, any Error>.completed(.success(21))
        let result = await sut.tryMap {
            (value: Int) async throws -> Int in await forceAsync(value + counter.value)
        }
        #expect(result.success == 121)
    }

    @Test("Async tryMap with mapError captures main-actor-isolated state")
    func tryMapWithMapError() async {
        let box = MainActorBox(100)
        let errorBox = MainActorBox(TestError.first)
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.tryMap(
            { (value: Int) async throws -> Int in await forceAsync(value + box.value) },
            mapError: { _ in errorBox.value }
        )
        #expect(result == .completed(.success(121)))
    }
}
