# SessionPlus

A collection of extensions &amp; wrappers around URLSession.

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
To install it into a project, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/SessionPlus.git", .upToNextMinor(from: "1.1.0")
    ],
    ...
)
```

Then import the **SessionPlus** packages wherever you'd like to use it:

```swift
import SessionPlus
```

## Quick Start

Checkout the `WebAPI` class.

```swift
open class WebAPI: HTTPClient, HTTPCodable, HTTPInjectable {
    
    public var baseURL: URL
    public var session: URLSession
    public var authorization: HTTP.Authorization?
    public var jsonEncoder: JSONEncoder = JSONEncoder()
    public var jsonDecoder: JSONDecoder = JSONDecoder()
    public var injectedResponses: [InjectedPath : InjectedResponse] = [:]
    …
    public init(baseURL: URL, session: URLSession? = nil, delegate: URLSessionDelegate? = nil) {
        …
    }
}
```

`WebAPI` provides a basic implementation for an _out-of-the-box_ HTTP/REST/JSON client.

## Components

### HTTPClient

```swift
public protocol HTTPClient {
    var baseURL: URL { get }
    var session: URLSession { get set }
    var authorization: HTTP.Authorization? { get set }
    func request(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest
    func task(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) throws -> URLSessionDataTask
    func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion)
}
```

`URLSession` is task-driven. The **SessionPlus** api is designed with this in mind; allowing you to construct your request and then either creating a _data task_ for you to references and execute, or automatically executing the request.

Example conformances for `request(method:path:queryItems:data:)`, `task(request:, completion)`, & `execute(request:completion:)` are provided in an extension, so the minimum required conformance to `HTTPClient` is `baseURL`, `session`, and `authorization`.

Convenience methods for the common HTTP request methods **get**, **put**, **post**, **delete**, and **patch**, are all provided.

### HTTPCodable

```swift
public protocol HTTPCodable {
    var jsonEncoder: JSONEncoder { get set }
    var jsonDecoder: JSONDecoder { get set }
}
```

The `HTTPCodable` protocol is used to extend an `HTTPClient` implementation with support for encoding and decoding of JSON bodies.

### HTTPInjectable

```swift
public protocol HTTPInjectable {
    var injectedResponses: [InjectedPath : InjectedResponse] { get set }
}
```

The `HTTPInjectable` protocol is used to extend an `HTTPClient` implementation by overriding the default `execute(request:completion:)` implementation to allow for the definition and usage of predefined responses. This makes for simple testing!
