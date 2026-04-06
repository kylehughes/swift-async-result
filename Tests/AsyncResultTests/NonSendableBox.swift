//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

/// A non-`Sendable` reference type for testing that closures can capture non-sendable values.
final class NonSendableBox<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
