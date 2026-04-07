# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

AsyncResult is a Swift package providing a single generic enum, `AsyncResult<Success, Failure>`, that extends `Result` with an `.inProgress` case to represent in-flight asynchronous operations. It targets iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+, and visionOS 1+ using Swift 6.2 with strict concurrency.

## Build & Test

```bash
swift build           # Build the package
swift test            # Run all tests
swift test --filter AsyncResultTests.testName  # Run a single test
```

### Coverage

This package maintains 100% line and function coverage. Verify with:

```bash
swift test --enable-code-coverage
xcrun llvm-cov report .build/debug/swift-async-resultPackageTests.xctest/Contents/MacOS/swift-async-resultPackageTests \
  --instr-profile .build/debug/codecov/default.profdata --sources Sources/
```

When adding new API surface, add tests that exercise every code path across all three logical states: `.inProgress`, `.completed(.success)`, `.completed(.failure)`. For `merge`/`zip`/`collect`, test the full state matrix. Minor region misses from unreachable `Never`-typed branches are expected.

## Architecture

The entire public API lives in `Sources/AsyncResult/AsyncResult.swift`. The type is a two-case enum (`.completed(Result)`, `.inProgress`) with initializers, computed properties, and combinators. All public members are `@inlinable` with doc comments.

Tests use Swift Testing (`import Testing`, `@Test`) in `Tests/AsyncResultTests/`, organized into `@Suite`s by functional area with one file per suite and one file per shared helper type.

## Conventions

- **No `// MARK:` comments** — deterministic symbol ordering makes navigational markers redundant.
- **Lexicographic symbol ordering** — within each type, members are ordered by access level, then alphabetically by identifier. Overloads of the same name are grouped together (sync before async). Suites and top-level types at file scope follow the same rule.
- **`@Test("...")` and `@Suite("...")`** — all test annotations include description strings. Test descriptions are declarative sentences asserting what the test proves.
- **`@inlinable`** on all public members.
- **`nonisolated(nonsending)`** on all async methods and their async closure parameters — ensures methods inherit the caller's isolation so closures awaited inline never cross an isolation boundary. Required because SE-0461 (`NonisolatedNonsendingByDefault`) is not yet the Swift 6.2 default. Sync closure parameters (e.g. `mapError:`) do not need the annotation.
- **Percolated `try`/`await`** — place `try` and `await` on the outermost expression (`self = try await .completed(.success(body()))`) rather than directly on the throwing/async call. This keeps the assignment visually uniform across overloads.
- **Overload pattern** — `init(catching:)` and `tryMap` both follow the same three-variant pattern: `throws(Failure)` (typed), `throws` with `where Failure == any Error` (untyped), and `throws` with `mapError:` (untyped with mapping). Each has sync + async overloads (6 total per family).
- **Async overloads** — each sync combinator has a corresponding `async` overload. When testing async overloads, closures must be genuinely async (use a helper like `forceAsync`) or the compiler will select the sync overload, resulting in missing coverage.
- **`tryMap` explicit returns** — methods with `do`/`catch` inside `switch` require explicit `return` on all branches; implicit return doesn't work when some branches have explicit `return`.
- **Combination priority** — `merge`, `zip`, and `collect` all use failure > inProgress > success priority, ensuring failures are never hidden by in-progress states.

## Design Decisions

- **No `case idle`** — `AsyncResult` is "Result plus loading," not a full operation lifecycle. Use `AsyncResult?` where `nil` represents idle/not-yet-started. This avoids adding a case that is algebraically identical to `.inProgress` in every combinator.
- **No `get() throws`** — the three-state nature makes any `get()` signature ambiguous for `.inProgress`. The `success`/`failure` optional properties and `result: Result?` cover extraction. For `Failure == Never`, use the `value` property.
- **No `Codable`** — `Error` isn't `Codable`, and persisting `.inProgress` is semantically questionable.
- **No `fold`** — Swift 5.9+ switch expressions provide the same exhaustive case elimination inline.
- **`Sendable` conformance** constrains only `Success: Sendable`, matching stdlib `Result`.
- **`isSuccess`/`isFailure` vs `success != nil`** — the booleans exist because `success != nil` is ambiguous when `Success` is `Optional` (double-optional `.some(nil)` makes `success != nil` return `true` for a `nil` success value).
