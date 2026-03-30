//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Properties")
struct AsyncResultPropertyTests {
    @Test("failure returns the error for a completed failure")
    func failureForFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        #expect(sut.failure == .first)
    }

    @Test("failure returns nil for in-progress")
    func failureForInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(sut.failure == nil)
    }

    @Test("failure returns nil for a completed success")
    func failureForSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(1))
        #expect(sut.failure == nil)
    }

    @Test("isCompleted is true for a completed failure")
    func isCompletedForFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        #expect(sut.isCompleted)
    }

    @Test("isCompleted is false for in-progress")
    func isCompletedForInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(!sut.isCompleted)
    }

    @Test("isCompleted is true for a completed success")
    func isCompletedForSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(1))
        #expect(sut.isCompleted)
    }

    @Test("isInProgress is false for a completed result")
    func isInProgressForCompleted() {
        let sut = AsyncResult<Int, TestError>.completed(.success(1))
        #expect(!sut.isInProgress)
    }

    @Test("isInProgress is true for in-progress")
    func isInProgressForInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(sut.isInProgress)
    }

    @Test("result returns the failure Result for a completed failure")
    func resultForFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        #expect(sut.result == .failure(.first))
    }

    @Test("result returns nil for in-progress")
    func resultForInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(sut.result == nil)
    }

    @Test("result returns the success Result for a completed success")
    func resultForSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        #expect(sut.result == .success(42))
    }

    @Test("success returns nil for a completed failure")
    func successForFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        #expect(sut.success == nil)
    }

    @Test("success returns nil for in-progress")
    func successForInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(sut.success == nil)
    }

    @Test("success returns the value for a completed success")
    func successForSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        #expect(sut.success == 42)
    }
}
