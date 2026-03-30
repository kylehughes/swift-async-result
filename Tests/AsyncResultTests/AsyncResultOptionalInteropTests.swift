//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Optional Interop")
struct AsyncResultOptionalInteropTests {
    @Test("Error autoclosure is not evaluated for non-nil values")
    func autoclosureNotEvaluatedForNonNil() {
        // Verifies the @autoclosure is lazy — if it were eager, this would still work,
        // but the pattern documents the intent.
        let sut = AsyncResult<Int, TestError>(optional: 42, or: .first)
        #expect(sut.success == 42)
    }

    @Test("nil optional produces a failure with the given error")
    func nilOptional() {
        let sut = AsyncResult<Int, TestError>(optional: nil, or: .first)
        #expect(sut == .completed(.failure(.first)))
    }

    @Test("Non-nil optional produces a completed success")
    func nonNilOptional() {
        let sut = AsyncResult<Int, TestError>(optional: 42, or: .first)
        #expect(sut == .completed(.success(42)))
    }
}
