//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("unwrap")
struct AsyncResultUnwrapTests {
    @Test("Unwrapping propagates an existing failure")
    func failure() {
        let sut = AsyncResult<Int?, TestError>.completed(.failure(.second))
        let unwrapped = sut.unwrap(or: .first)
        #expect(unwrapped == .completed(.failure(.second)))
    }

    @Test("Unwrapping preserves in-progress")
    func inProgress() {
        let sut = AsyncResult<Int?, TestError>.inProgress
        let unwrapped = sut.unwrap(or: .first)
        #expect(unwrapped == .inProgress)
    }

    @Test("Unwrapping a nil success produces a failure")
    func nilSuccess() {
        let sut = AsyncResult<Int?, TestError>.completed(.success(nil))
        let unwrapped = sut.unwrap(or: .first)
        #expect(unwrapped == .completed(.failure(.first)))
    }

    @Test("Unwrapping a non-nil success extracts the value")
    func nonNilSuccess() {
        let sut = AsyncResult<Int?, TestError>.completed(.success(42))
        let unwrapped = sut.unwrap(or: .first)
        #expect(unwrapped == .completed(.success(42)))
    }
}
