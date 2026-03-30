//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("map")
struct AsyncResultMapTests {
    @Test("Async mapping preserves failure")
    func asyncMapFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let mapped = await sut.map { await forceAsync($0 * 2) }
        #expect(mapped == .completed(.failure(.first)))
    }

    @Test("Async mapping preserves in-progress")
    func asyncMapInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let mapped = await sut.map { await forceAsync($0 * 2) }
        #expect(mapped == .inProgress)
    }

    @Test("Async mapping transforms the success value")
    func asyncMapSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let mapped = await sut.map { await forceAsync($0 * 2) }
        #expect(mapped == .completed(.success(42)))
    }

    @Test("Mapping preserves failure")
    func mapFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let mapped = sut.map { $0 * 2 }
        #expect(mapped == .completed(.failure(.first)))
    }

    @Test("Mapping preserves in-progress")
    func mapInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let mapped = sut.map { $0 * 2 }
        #expect(mapped == .inProgress)
    }

    @Test("Mapping transforms the success value")
    func mapSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let mapped = sut.map { $0 * 2 }
        #expect(mapped == .completed(.success(42)))
    }
}
