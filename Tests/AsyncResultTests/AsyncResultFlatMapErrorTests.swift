//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("flatMapError")
struct AsyncResultFlatMapErrorTests {
    @Test("Async flat-mapping a failure can recover to success")
    func asyncFlatMapErrorFailureToSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = await sut.flatMapError { _ in
            await forceAsync(AsyncResult<Int, OtherError>.completed(.success(99)))
        }
        #expect(result == .completed(.success(99)))
    }

    @Test("Async flat-mapping error preserves in-progress")
    func asyncFlatMapErrorInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = await sut.flatMapError { _ in
            await forceAsync(AsyncResult<Int, OtherError>.completed(.failure(.mapped)))
        }
        #expect(result == .inProgress)
    }

    @Test("Async flat-mapping error preserves success")
    func asyncFlatMapErrorSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        let result = await sut.flatMapError { _ in
            await forceAsync(AsyncResult<Int, OtherError>.completed(.failure(.mapped)))
        }
        #expect(result == .completed(.success(42)))
    }

    @Test("Flat-mapping a failure can produce a new failure")
    func flatMapErrorFailureToFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = sut.flatMapError { _ in AsyncResult<Int, OtherError>.completed(.failure(.mapped)) }
        #expect(result == .completed(.failure(.mapped)))
    }

    @Test("Flat-mapping a failure can produce in-progress")
    func flatMapErrorFailureToInProgress() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = sut.flatMapError { _ in AsyncResult<Int, OtherError>.inProgress }
        #expect(result == .inProgress)
    }

    @Test("Flat-mapping a failure can recover to success")
    func flatMapErrorFailureToSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = sut.flatMapError { _ in AsyncResult<Int, OtherError>.completed(.success(99)) }
        #expect(result == .completed(.success(99)))
    }

    @Test("Flat-mapping error preserves in-progress")
    func flatMapErrorInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = sut.flatMapError { _ in AsyncResult<Int, OtherError>.completed(.failure(.mapped)) }
        #expect(result == .inProgress)
    }

    @Test("Flat-mapping error preserves success")
    func flatMapErrorSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        let result = sut.flatMapError { _ in AsyncResult<Int, OtherError>.completed(.failure(.mapped)) }
        #expect(result == .completed(.success(42)))
    }
}
