//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("setFailureType")
struct AsyncResultSetFailureTypeTests {
    @Test("Setting failure type preserves the success value")
    func completedSuccess() {
        let sut = AsyncResult<Int, Never>.completed(.success(42))
        let result: AsyncResult<Int, TestError> = sut.setFailureType(to: TestError.self)
        #expect(result == .completed(.success(42)))
    }

    @Test("setFailureType enables zipping infallible with fallible results")
    func composesWithZip() {
        let infallible = AsyncResult<Int, Never>(42)
        let fallible = AsyncResult<String, TestError>.completed(.success("x"))
        let zipped = infallible.setFailureType(to: TestError.self).zip(with: fallible)
        #expect(zipped.success?.0 == 42)
        #expect(zipped.success?.1 == "x")
    }

    @Test("Setting failure type preserves in-progress")
    func inProgress() {
        let sut = AsyncResult<Int, Never>.inProgress
        let result: AsyncResult<Int, TestError> = sut.setFailureType(to: TestError.self)
        #expect(result == .inProgress)
    }
}
