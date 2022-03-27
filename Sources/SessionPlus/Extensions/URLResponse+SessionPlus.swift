import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLResponse {
    /// `StatusCode` from the `HTTPURLResponse` interpreted response.
    var statusCode: StatusCode {
        guard let httpResponse = self as? HTTPURLResponse else {
            return 0
        }
        
        return StatusCode(integerLiteral: httpResponse.statusCode)
    }
    
    /// Headers from the `HTTPURLResponse` interpreted response.
    var headers: Headers {
        guard let httpResponse = self as? HTTPURLResponse else {
            return [:]
        }
        
        let pairs = httpResponse.allHeaderFields.compactMap { (key: AnyHashable, value: Any) -> (String, String) in
            let stringKey = (key as? String) ?? String(describing: key)
            let stringValue = (value as? String) ?? String(describing: value)
            return (stringKey, stringValue)
        }
        
        return Dictionary<String, String>.init(uniqueKeysWithValues: pairs)
    }
}
