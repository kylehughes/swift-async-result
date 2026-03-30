//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("map(success:failure:)")
struct AsyncResultMapBothTests {
    @Test("Async mapping both transforms the failure")
    func asyncMapBothFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = await sut.map(
            success: { await forceAsync($0 * 2) },
            failure: { _ in await forceAsync(OtherError.mapped) }
        )
        #expect(result == .completed(.failure(.mapped)))
    }

    @Test("Async mapping both preserves in-progress")
    func asyncMapBothInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = await sut.map(
            success: { await forceAsync($0 * 2) },
            failure: { _ in await forceAsync(OtherError.mapped) }
        )
        #expect(result == .inProgress)
    }

    @Test("Async mapping both transforms the success")
    func asyncMapBothSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = await sut.map(
            success: { await forceAsync($0 * 2) },
            failure: { _ in await forceAsync(OtherError.mapped) }
        )
        #expect(result == .completed(.success(42)))
    }

    @Test("Mapping both transforms the failure")
    func mapBothFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = sut.map(success: { $0 * 2 }, failure: { _ in OtherError.mapped })
        #expect(result == .completed(.failure(.mapped)))
    }

    @Test("Mapping both preserves in-progress")
    func mapBothInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = sut.map(success: { $0 * 2 }, failure: { _ in OtherError.mapped })
        #expect(result == .inProgress)
    }

    @Test("Mapping both transforms the success")
    func mapBothSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(21))
        let result = sut.map(success: { $0 * 2 }, failure: { _ in OtherError.mapped })
        #expect(result == .completed(.success(42)))
    }
}
