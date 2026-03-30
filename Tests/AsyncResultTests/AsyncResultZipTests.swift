//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("zip")
struct AsyncResultZipTests {
    @Test("Zipping two successes produces a tuple")
    func bothSuccess() {
        let a = AsyncResult<Int, TestError>.completed(.success(2))
        let b = AsyncResult<String, TestError>.completed(.success("x"))
        let result = a.zip(with: b)
        #expect(result.success?.0 == 2)
        #expect(result.success?.1 == "x")
    }

    @Test("Zipping propagates the first failure")
    func firstFailure() {
        let a = AsyncResult<Int, TestError>.completed(.failure(.first))
        let b = AsyncResult<String, TestError>.completed(.success("x"))
        let result = a.zip(with: b)
        #expect(result.failure == .first)
    }

    @Test("Zipping propagates in-progress")
    func firstInProgress() {
        let a = AsyncResult<Int, TestError>.inProgress
        let b = AsyncResult<String, TestError>.completed(.success("x"))
        let result = a.zip(with: b)
        #expect(result.isInProgress)
    }

    @Test("Failure takes priority over in-progress when zipping")
    func inProgressWithFailurePrefersFailure() {
        let a = AsyncResult<Int, TestError>.inProgress
        let b = AsyncResult<String, TestError>.completed(.failure(.second))
        let result = a.zip(with: b)
        #expect(result.failure == .second)
    }

    @Test("Zipping propagates the second failure")
    func secondFailure() {
        let a = AsyncResult<Int, TestError>.completed(.success(2))
        let b = AsyncResult<String, TestError>.completed(.failure(.second))
        let result = a.zip(with: b)
        #expect(result.failure == .second)
    }
}
