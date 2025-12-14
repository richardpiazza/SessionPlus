# SessionPlus

A swift _request & response_ framework for JSON apis.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FSessionPlus%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/richardpiazza/SessionPlus)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FSessionPlus%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/richardpiazza/SessionPlus)

This package has been designed to work across multiple swift environments by utilizing conditional checks. It has been tested on Apple platforms (macOS, iOS, tvOS, watchOS), as well as Linux (Ubuntu).

## Usage

**SessionPlus** offers a default implementation (`URLSessionClient`) that allows for requesting data from a JSON api. For example:

```swift
let url = URL(string: "https://api.agify.io")!
let client = BaseURLSessionClient(baseURL: url)
let request = Get(queryItems: [URLQueryItem(name: "name", value: "bob")])
let response = try await client.request(request)
```

### Decoding

The `Client` protocol also offers extensions for automatically decoding responses to any `Decodable` type.

```swift
struct ApiResult: Decodable {
  let name: String
  let age: Int
  let count: Int
}


let response = try await client.request(request) as ApiResult
...
let response: ApiResult = try await client.request(request)
```

## Installation

**SessionPlus** is distributed using the [Swift Package Manager](https://swift.org/package-manager). 
You can add it using Xcode or by listing it as a dependency in your `Package.swift` manifest:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/richardpiazza/SessionPlus.git", .upToNextMajor(from: "2.0.0")
  ],
  ...
  targets: [
    .target(
      name: "MyPackage",
      dependencies: [
        .product(name: "SessionPlus", package: "SessionPlus"),
      ]
    )
  ]
)
```

## Contribution

Contributions to **SessionPlus** are welcomed and encouraged! See the [Contribution Guide](CONTRIBUTING.md) for more information.
