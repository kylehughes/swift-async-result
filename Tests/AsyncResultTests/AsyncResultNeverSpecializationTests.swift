//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Never Specialization")
struct AsyncResultNeverSpecializationTests {
    @Test("Convenience initializer wraps a value for Never failure")
    func initConvenience() {
        let sut = AsyncResult<Int, Never>(42)
        #expect(sut.value == 42)
    }

    @Test("value returns the success for a completed Never-failure result")
    func valueForCompleted() {
        let sut = AsyncResult<Int, Never>.completed(.success(42))
        #expect(sut.value == 42)
    }

    @Test("value returns nil for an in-progress Never-failure result")
    func valueForInProgress() {
        let sut = AsyncResult<Int, Never>.inProgress
        #expect(sut.value == nil)
    }
}
