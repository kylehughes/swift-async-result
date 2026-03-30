//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Conformances")
struct AsyncResultConformanceTests {
    @Test("Failure description includes the error")
    func descriptionFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        #expect(sut.description.hasPrefix("AsyncResult.completed(failure("))
        #expect(sut.description.hasSuffix("))"))
    }

    @Test("In-progress description is AsyncResult.inProgress")
    func descriptionInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        #expect(sut.description == "AsyncResult.inProgress")
    }

    @Test("Success description includes the value")
    func descriptionSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        #expect(sut.description == "AsyncResult.completed(success(42))")
    }

    @Test("Equal completed values are equal")
    func equatableEqual() {
        let a = AsyncResult<Int, TestError>.completed(.success(1))
        let b = AsyncResult<Int, TestError>.completed(.success(1))
        #expect(a == b)
    }

    @Test("Two in-progress values are equal")
    func equatableInProgress() {
        let a = AsyncResult<Int, TestError>.inProgress
        let b = AsyncResult<Int, TestError>.inProgress
        #expect(a == b)
    }

    @Test("Completed and in-progress are not equal")
    func equatableMixedCases() {
        let a = AsyncResult<Int, TestError>.completed(.success(1))
        let b = AsyncResult<Int, TestError>.inProgress
        #expect(a != b)
    }

    @Test("Different completed values are not equal")
    func equatableNotEqual() {
        let a = AsyncResult<Int, TestError>.completed(.success(1))
        let b = AsyncResult<Int, TestError>.completed(.success(2))
        #expect(a != b)
    }

    @Test("Equal values produce equal hash values")
    func hashableConsistency() {
        let a = AsyncResult<Int, TestError>.completed(.success(42))
        let b = AsyncResult<Int, TestError>.completed(.success(42))
        #expect(a.hashValue == b.hashValue)
    }

    @Test("Duplicate values are deduplicated in a Set")
    func hashableInSet() {
        let set: Set<AsyncResult<Int, TestError>> = [
            .completed(.success(1)),
            .completed(.success(1)),
            .inProgress,
        ]
        #expect(set.count == 2)
    }
}
