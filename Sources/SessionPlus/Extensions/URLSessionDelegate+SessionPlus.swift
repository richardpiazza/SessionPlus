import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(ObjectiveC)
public extension URLSessionDelegate {
    /// A preconfigured URLSessionDelegate that will ignore invalid/self-signed SSL Certificates.
    static var selfSigned: URLSessionDelegate { SelfSignedSessionDelegate() }
}

public class SelfSignedSessionDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.previousFailureCount < 1 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var credentials: URLCredential?
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                credentials = URLCredential(trust: serverTrust)
            }
        }

        completionHandler(.useCredential, credentials)
    }
}
#endif
