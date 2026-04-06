//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

/// Forces the compiler to treat the closure as async.
func forceAsync<T>(_ value: T) async -> T {
    value
}
