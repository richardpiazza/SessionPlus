import Foundation

public extension HTTP {
    /// Authorization schemes used in the API
    enum Authorization {
        case basic(username: String, password: String?)
        case bearer(token: String)
        case custom(headerField: String, headerValue: String)
        
        public var headerValue: String {
            switch self {
            case .basic(let username, let password):
                let pwd = password ?? ""
                guard let data = "\(username):\(pwd)".data(using: .utf8) else {
                    return ""
                }
                
                let base64 = data.base64EncodedString(options: [])
                
                return "Basic \(base64)"
            case .bearer(let token):
                return "Bearer \(token)"
            case .custom(let headerField, let headerValue):
                return "\(headerField) \(headerValue))"
            }
        }
    }
}
