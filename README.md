# SessionPlus

A swift _request & response_ framework for JSON apis.

<p>
 <img src="https://github.com/richardpiazza/SessionPlus/workflows/Swift/badge.svg?branch=main" />
 <img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
 <a href="https://twitter.com/richardpiazza">
 <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
 </a>
</p>

This package has been designed to work across multiple swift environments by utilizing conditional checks. It has been tested on Apple platforms (macOS, iOS, tvOS, watchOS), as well as Linux (Ubuntu).

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
      dependnecies: [
        "SessionPlus"
      ]
    )
  ]
)
```

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

### Flexibility

The `Client` protocol declares up to three forms requests based on platform abilities:

```swift
// async/await for swift 5.5+
func performRequest(_ request: Request) async throws -> Response
// completion handler for backwards compatibility
func performRequest(_ request: Request, completion: @escaping (Result<Response, Error>) -> Void)
// Combine publisher that emits with a response
func performRequest(_ request: Request) -> AnyPublisher<Response, Error>
```

## Contribution

Contributions to **SessionPlus** are welcomed and encouraged! See the [Contribution Guide](CONTRIBUTING.md) for more information.
