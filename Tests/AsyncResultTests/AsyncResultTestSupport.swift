//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

import Testing

@testable import AsyncResult

enum OtherError: Error, Equatable {
    case mapped
}

enum TestError: Error, Equatable {
    case first
    case second
}

/// Forces the compiler to treat the closure as async.
func forceAsync<T>(_ value: T) async -> T {
    value
}
