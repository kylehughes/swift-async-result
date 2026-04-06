# AsyncResult

[![Platform Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkylehughes%2Fswift-async-result%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kylehughes/swift-async-result)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkylehughes%2Fswift-async-result%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kylehughes/swift-async-result)
[![Test](https://github.com/kylehughes/swift-async-result/actions/workflows/test.yml/badge.svg)](https://github.com/kylehughes/swift-async-result/actions/workflows/test.yml)

`Result`, extended with an in-progress case for asynchronous operations, e.g.

```swift
enum AsyncResult<Success, Failure: Error> {
    case completed(Result<Success, Failure>)
    case inProgress
}
```

## About

AsyncResult adds an `.inProgress` case to `Result` for representing loading, success, and failure states.

AsyncResult has no dependencies. Tests cover 100% of lines and functions.

### Capabilities

* Combinators: `map`, `flatMap`, `mapError`, `flatMapError`, `tryMap`, `merge`, `zip`, `collect`.
* Typed throws support across all throwing APIs.
* `recover` with type-level proof (`AsyncResult<Success, Never>`) that recovery occurred.
* `Failure == Never` specialization with `value`, `setFailureType(to:)`.
* Optional interop: `init(optional:or:)`, `unwrap(or:)`.
* Sync and async overloads for all combinators.
* Swift 6 language mode support with strict concurrency.

## Supported Platforms

* iOS 13.0+
* macOS 10.15+
* tvOS 13.0+
* visionOS 1.0+
* watchOS 6.0+

## Requirements

* Swift 6.2+
* Xcode 26.0+

## Documentation

[Documentation is available on GitHub Pages.](https://kylehughes.github.io/swift-async-result/)

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/kylehughes/swift-async-result.git", .upToNextMajor(from: "1.0.0")),
]
```

## Getting Started

`AsyncResult?` serves as view model state, where `nil` means idle:

```swift
import AsyncResult

@Observable
final class UserViewModel {
    var user: AsyncResult<User, any Error>?

    func load() async {
        user = .inProgress
        user = await AsyncResult { try await api.fetchUser() }
    }
}
```

Chain transformations, including throwing ones, on the result:

```swift
let displayName = user
    .map(\.profile)
    .tryMap { try JSONDecoder().decode(Profile.self, from: $0) }
    .map(\.displayName)
```

Recover from errors with type-level proof:

```swift
let safeResult: AsyncResult<String, Never> = user
    .map(\.name)
    .recover { _ in "Unknown" }

// nil only when in progress; failure is impossible
let name = safeResult.value
```

Combine multiple in-flight requests:

```swift
let combined = profileResult.zip(with: settingsResult)
// or collect a whole array:
let all = AsyncResult.collect(itemResults)
```

## Usage

### State Modeling

`AsyncResult` has two cases: `.inProgress` and `.completed(Result<Success, Failure>)`. Use `AsyncResult?` where `nil`
represents idle, before any operation has been initiated.

```swift
@State private var result: AsyncResult<[Item], any Error>?

var body: some View {
    switch result {
    case nil: ContentUnavailableView("Tap to load", ...)
    case .inProgress: ProgressView()
    case .completed(.success(let items)): ItemListView(items: items)
    case .completed(.failure(let error)): ErrorView(error: error)
    }
}
```

### Throwing Transforms

`tryMap` transforms the success value with a closure that can fail. It follows the same overload pattern as
`init(catching:)`:

```swift
// Typed throws: the closure throws the Failure type directly
result.tryMap { (data: Data) throws(APIError) -> User in
    try decoder.decode(User.self, from: data)
}

// Untyped throws with error mapping
result.tryMap(
    { try JSONDecoder().decode(User.self, from: $0) },
    mapError: { _ in .decodingFailed }
)
```

### Combining Results

`merge`, `zip`, and `collect` all use the same priority: failure > inProgress > success.

```swift
// Zip two results into a tuple
let combined = profileResult.zip(with: avatarResult)

// Merge with a custom transform
let summary = nameResult.merge(with: ageResult) { "\($0), \($1)" }

// Collect an array of results
let allItems = AsyncResult.collect(itemResults)  // AsyncResult<[Item], any Error>
```

### Recovery and Never

`recover` transforms failures into successes and returns `AsyncResult<Success, Never>`:

```swift
let safe = result.recover { _ in fallbackValue }
safe.value  // nil only means in-progress
```

`setFailureType(to:)` composes infallible results with fallible ones:

```swift
let infallible = AsyncResult<Int, Never>(42)
let fallible = AsyncResult<String, MyError>.completed(.success("hello"))
let zipped = infallible.setFailureType(to: MyError.self).zip(with: fallible)
```

### Optional Interop

```swift
// Create from an optional
let result = AsyncResult(optional: cachedUser, or: CacheError.miss)

// Unwrap an optional success value
let unwrapped: AsyncResult<User, any Error> = result.unwrap(or: APIError.notFound)
```

## Important Behavior

* `AsyncResult` does not have an idle case. Use `AsyncResult?` where `nil` represents the state before any operation
  has been initiated.
* `merge`, `zip`, and `collect` use failure > inProgress > success priority. A failure in any position is never hidden
  by an in-progress state elsewhere.
* `recover` returns `AsyncResult<Success, Never>`, which proves at the type level that error handling has occurred. The
  `value` property on `Never`-failure results returns `nil` only for in-progress, never for failure.

## Contributions

AsyncResult is not accepting source contributions at this time. Bug reports will be considered.

## Author

[Kyle Hughes](https://kylehugh.es)

[![Bluesky][bluesky_image]][bluesky_url]  
[![LinkedIn][linkedin_image]][linkedin_url]  
[![Mastodon][mastodon_image]][mastodon_url]

[bluesky_image]: https://img.shields.io/badge/Bluesky-0285FF?logo=bluesky&logoColor=fff
[bluesky_url]: https://bsky.app/profile/kylehugh.es
[linkedin_image]: https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=fff
[linkedin_url]: https://www.linkedin.com/in/kyle-hughes
[mastodon_image]: https://img.shields.io/mastodon/follow/109356914477272810?domain=https%3A%2F%2Fmister.computer&style=social
[mastodon_url]: https://mister.computer/@kyle

## License

AsyncResult is available under the MIT license.

See `LICENSE` for details.
