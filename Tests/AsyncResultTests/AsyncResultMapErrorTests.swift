//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

@Suite("mapError")
struct AsyncResultMapErrorTests {
    @Test("Async mapping error transforms the failure")
    func asyncMapErrorFailure() async {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = await sut.mapError { _ in await forceAsync(OtherError.mapped) }
        #expect(result == .completed(.failure(.mapped)))
    }

    @Test("Async mapping error preserves in-progress")
    func asyncMapErrorInProgress() async {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = await sut.mapError { _ in await forceAsync(OtherError.mapped) }
        #expect(result == .inProgress)
    }

    @Test("Async mapping error preserves success")
    func asyncMapErrorSuccess() async {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        let result = await sut.mapError { _ in await forceAsync(OtherError.mapped) }
        #expect(result == .completed(.success(42)))
    }

    @Test("Mapping error transforms the failure")
    func mapErrorFailure() {
        let sut = AsyncResult<Int, TestError>.completed(.failure(.first))
        let result = sut.mapError { _ in OtherError.mapped }
        #expect(result == .completed(.failure(.mapped)))
    }

    @Test("Mapping error preserves in-progress")
    func mapErrorInProgress() {
        let sut = AsyncResult<Int, TestError>.inProgress
        let result = sut.mapError { _ in OtherError.mapped }
        #expect(result == .inProgress)
    }

    @Test("Mapping error preserves success")
    func mapErrorSuccess() {
        let sut = AsyncResult<Int, TestError>.completed(.success(42))
        let result = sut.mapError { _ in OtherError.mapped }
        #expect(result == .completed(.success(42)))
    }
}
