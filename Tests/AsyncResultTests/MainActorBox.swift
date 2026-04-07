//
//  Copyright © 2026 Kyle Hughes. All rights reserved.
//

/// A `@MainActor`-isolated reference type for testing that closures can capture actor-isolated state.
@MainActor final class MainActorBox<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
