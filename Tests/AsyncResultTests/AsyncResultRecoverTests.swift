//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("recover")
struct AsyncResultRecoverTests {
    @Test("Async recovery transforms a failure into a success")
    func asyncRecoverFromFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let recovered = await sut.recover { _ in await forceAsync(99) }
        #expect(recovered == .completed(.success(99)))
    }

    @Test("Async recovery preserves in-progress")
    func asyncRecoverFromInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let recovered = await sut.recover { _ in await forceAsync(99) }
        #expect(recovered == .inProgress)
    }

    @Test("Async recovery preserves an existing success")
    func asyncRecoverFromSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        let recovered = await sut.recover { _ in await forceAsync(99) }
        #expect(recovered == .completed(.success(42)))
    }

    @Test("Recovery transforms a failure into a success")
    func recoverFromFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let recovered = sut.recover { _ in 99 }
        #expect(recovered == .completed(.success(99)))
    }

    @Test("Recovery preserves in-progress")
    func recoverFromInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let recovered = sut.recover { _ in 99 }
        #expect(recovered == .inProgress)
    }

    @Test("Recovery preserves an existing success")
    func recoverFromSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        let recovered = sut.recover { _ in 99 }
        #expect(recovered == .completed(.success(42)))
    }

    @Test("Recovery produces an AsyncResult with Never failure type")
    func recoverProducesNeverFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let recovered: AsyncResult<Int, Never> = sut.recover { _ in 0 }
        #expect(recovered.value == 0)
    }
}
