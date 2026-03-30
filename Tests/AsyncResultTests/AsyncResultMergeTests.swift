//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("merge")
struct AsyncResultMergeTests {
    @Test("Merging two failures returns the first failure")
    func bothFailure() {
        let a = AsyncResult<Int, TestError>.completed(.failure(.first))
        let b = AsyncResult<String, TestError>.completed(.failure(.second))
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Merging two in-progress returns in-progress")
    func bothInProgress() {
        let a = AsyncResult<Int, TestError>.inProgress
        let b = AsyncResult<String, TestError>.inProgress
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .inProgress)
    }

    @Test("Merging two successes combines their values")
    func bothSuccess() {
        let a = AsyncResult<Int, TestError>.completed(.success(2))
        let b = AsyncResult<String, TestError>.completed(.success("x"))
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .completed(.success("2x")))
    }

    @Test("Merging propagates the first failure")
    func firstFailure() {
        let a = AsyncResult<Int, TestError>.completed(.failure(.first))
        let b = AsyncResult<String, TestError>.completed(.success("x"))
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Failure takes priority over in-progress from second")
    func firstFailureSecondInProgress() {
        let a = AsyncResult<Int, TestError>.completed(.failure(.first))
        let b = AsyncResult<String, TestError>.inProgress
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .completed(.failure(.first)))
    }

    @Test("Merging propagates in-progress from the first")
    func firstInProgress() {
        let a = AsyncResult<Int, TestError>.inProgress
        let b = AsyncResult<String, TestError>.completed(.success("x"))
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .inProgress)
    }

    @Test("Failure takes priority over in-progress from first")
    func firstInProgressSecondFailure() {
        let a = AsyncResult<Int, TestError>.inProgress
        let b = AsyncResult<String, TestError>.completed(.failure(.second))
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .completed(.failure(.second)))
    }

    @Test("Merging propagates the second failure")
    func secondFailure() {
        let a = AsyncResult<Int, TestError>.completed(.success(2))
        let b = AsyncResult<String, TestError>.completed(.failure(.second))
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .completed(.failure(.second)))
    }

    @Test("Merging propagates in-progress from the second")
    func secondInProgress() {
        let a = AsyncResult<Int, TestError>.completed(.success(2))
        let b = AsyncResult<String, TestError>.inProgress
        let result = a.merge(with: b) { "\($0)\($1)" }
        #expect(result == .inProgress)
    }
}
