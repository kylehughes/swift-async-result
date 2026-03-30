//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("flatMap")
struct AsyncResultFlatMapTests {
    @Test("Async flat-mapping preserves failure")
    func asyncFlatMapFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = await sut.flatMap {
            await forceAsync(AsyncResult<Int, TestError>.completed(.success($0 * 2)))
        }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Async flat-mapping preserves in-progress")
    func asyncFlatMapInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = await sut.flatMap {
            await forceAsync(AsyncResult<Int, TestError>.completed(.success($0 * 2)))
        }
        #expect(result == .inProgress)
    }

    @Test("Async flat-mapping a success transforms the value")
    func asyncFlatMapSuccessToSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.flatMap {
            await forceAsync(AsyncResult<Int, TestError>.completed(.success($0 * 2)))
        }
        #expect(result == .completed(.success(42)))
    }

    @Test("Flat-mapping preserves failure")
    func flatMapFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = sut.flatMap { .completed(.success($0 * 2)) }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Flat-mapping preserves in-progress")
    func flatMapInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = sut.flatMap { .completed(.success($0 * 2)) }
        #expect(result == .inProgress)
    }

    @Test("Flat-mapping a success can produce a failure")
    func flatMapSuccessToFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.flatMap { _ in AsyncResult<String, TestError>.completed(.failure(.first)) }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Flat-mapping a success can produce in-progress")
    func flatMapSuccessToInProgress() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.flatMap { _ in AsyncResult<String, TestError>.inProgress }
        #expect(result == .inProgress)
    }

    @Test("Flat-mapping a success transforms the value")
    func flatMapSuccessToSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.flatMap { .completed(.success($0 * 2)) }
        #expect(result == .completed(.success(42)))
    }
}
