//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("isSuccess and isFailure")
struct AsyncResultIsSuccessIsFailureTests {
    @Test("isFailure is true for a completed failure")
    func isFailureForFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        #expect(sut.isFailure)
        #expect(!sut.isSuccess)
    }

    @Test("isSuccess is true for a completed success")
    func isSuccessForSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        #expect(sut.isSuccess)
        #expect(!sut.isFailure)
    }

    @Test("Neither isSuccess nor isFailure is true for in-progress")
    func neitherForInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(!sut.isSuccess)
        #expect(!sut.isFailure)
    }

    @Test("isSuccess is unambiguous when Success is Optional")
    func worksWithOptionalSuccess() {
        let sut = AsyncResult<Int?, TestError>.completed(.success(nil))
        // isSuccess is unambiguous even when Success is Optional
        #expect(sut.isSuccess)
        // success returns Int?? here — .some(nil) — so success != nil is true,
        // which is why isSuccess is the better predicate for optional Success types.
        #expect(sut.success != nil)
    }
}
