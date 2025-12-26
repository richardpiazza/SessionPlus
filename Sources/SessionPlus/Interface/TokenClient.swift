import Foundation

public protocol TokenClient: Client {
    var authenticator: any TokenAuthenticator { get }
}

public extension TokenClient {
    func validatedToken() async throws -> any BearerToken {
        guard let token = authenticator.token else {
            await authenticator.reset()
            throw URLError(.userAuthenticationRequired)
        }
        
        guard token.canRenew else {
            await authenticator.reset()
            throw URLError(.userAuthenticationRequired)
        }
        
        return if token.isNearingExpiration {
            try await authenticator.renewToken()
        } else {
            token
        }
    }
    
    func authorizeRequest(_ request: any Request) async throws -> any Request {
        let token = try await validatedToken()
        return request.authorized(.bearer(token: token.accessToken))
    }
    
    func performAuthorizedRequest(_ request: any Request) async throws -> any Response {
        let authorizedRequest = try await authorizeRequest(request)
        let response = try await performRequest(authorizedRequest)
        
        if response.statusCode == .unauthorized {
            await authenticator.reset()
        }
        
        return response
    }
    
    func performAuthorizedRequest<Content>(
        _ request: any Request,
        using decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Content where Content: Decodable {
        let response = try await performAuthorizedRequest(request)
        return try decoder.decode(Content.self, from: response.body)
    }
}
