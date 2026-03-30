//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("Collect")
struct AsyncResultCollectTests {
    @Test("Collecting all-success results produces an array of values")
    func allSuccess() {
        let results: [AsyncResult<Int, TestError>] = [
            .completed(.success(1)),
            .completed(.success(2)),
            .completed(.success(3)),
        ]
        let collected = AsyncResult.collect(results)
        #expect(collected == .completed(.success([1, 2, 3])))
    }

    @Test("Collecting an empty sequence produces an empty success array")
    func empty() {
        let results: [AsyncResult<Int, TestError>] = []
        let collected = AsyncResult.collect(results)
        #expect(collected == .completed(.success([])))
    }

    @Test("Failure takes priority over in-progress when collecting")
    func failureTakesPriorityOverInProgress() {
        let results: [AsyncResult<Int, TestError>] = [
            .inProgress,
            .completed(.failure(.first)),
            .completed(.success(3)),
        ]
        let collected = AsyncResult.collect(results)
        #expect(collected == .completed(.failure(.first)))
    }

    @Test("Collecting returns the first failure encountered")
    func oneFailure() {
        let results: [AsyncResult<Int, TestError>] = [
            .completed(.success(1)),
            .completed(.failure(.first)),
            .completed(.success(3)),
        ]
        let collected = AsyncResult.collect(results)
        #expect(collected == .completed(.failure(.first)))
    }

    @Test("Collecting returns in-progress if any result is in progress")
    func oneInProgress() {
        let results: [AsyncResult<Int, TestError>] = [
            .completed(.success(1)),
            .inProgress,
            .completed(.success(3)),
        ]
        let collected = AsyncResult.collect(results)
        #expect(collected == .inProgress)
    }
}
