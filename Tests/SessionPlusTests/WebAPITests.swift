import XCTest
@testable import SessionPlus

final class WebAPITests: XCTestCase {
    
    private var api: WebAPI?
    
    override func setUp() {
        super.setUp()
        
        api = WebAPI(baseURL: URL(string: "http://www.example.com/api")!)
        guard let webApi = api else {
            XCTFail("WebAPI is nil")
            return
        }
        
        let responseObject: AnyObject = ["name":"Mock Me"] as AnyObject
        var data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
        } catch {
            print(error)
            XCTFail()
            return
        }
        
        let injectedResponse = InjectedResponse(statusCode: 200, timeout: 2, result: .success(data))
        webApi.injectedResponses[InjectedPath(absolutePath: "http://www.example.com/api/test")] = injectedResponse
    }
    
    func testInjectedResponse() {
        let expectation = self.expectation(description: "Injected Response")
        
        api!.get("test") { (statusCode, headers, data, error) in
            XCTAssertTrue(statusCode == 200)
            XCTAssertNotNil(data)
            
            let dictionary: [String: String]
            do {
                dictionary = try self.dictionary(data!)
            } catch {
                XCTFail(error.localizedDescription)
                return
            }
            
            guard dictionary["name"] == "Mock Me" else {
                XCTFail()
                return
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            if let _ = error {
                XCTFail()
            }
        }
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testInjectedResponseAsync() async throws {
        #if canImport(ObjectiveC)
        let response = try await api!.get("test", queryItems: nil)
        XCTAssertEqual(response.statusCode, 200)
        let dictionary = try self.dictionary(response.data)
        XCTAssertEqual(dictionary["name"], "Mock Me")
        #endif
    }
    
    func testIPv6DNSError() {
        #if canImport(ObjectiveC)
        // Temporarily disabled until debugging on Linux can be done.
        let expectation = self.expectation(description: "IPv6 DNS Error")
        
        let invalidApi = WebAPI(baseURL: URL(string: "https://api.richardpiazza.com")!)
        invalidApi.get("") { (statusCode, response, responseObject, error) in
            guard error != nil else {
                XCTFail("Did not receive expected error.")
                return
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
        #endif
    }
}

private extension WebAPITests {
    func dictionary(_ data: Data) throws -> [String: String] {
        let dictionaryData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
        guard let dictionary = dictionaryData as? [String: String] else {
            throw NSError(domain: "WebAPITests.dictionary()", code: 0, userInfo: nil)
        }
        return dictionary
    }
}
