import XCTest
@testable import SessionPlus

class WebAPITests: XCTestCase {
    
    static var allTests = [
        ("testInjectedResponse", testInjectedResponse),
        ("testIPv6DNSError", testIPv6DNSError),
    ]
    
    var api: WebAPI?
    
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
        
        let injectedResponse = InjectedResponse(statusCode: 200, headers: nil, data: data, error: nil, timeout: 2)
        webApi.injectedResponses[InjectedPath(absolutePath: "http://www.example.com/api/test")] = injectedResponse
    }
    
    func testInjectedResponse() {
        let expectation = self.expectation(description: "Injected Response")
        
        api!.get("test") { (statusCode, headers, data, error) in
            XCTAssertTrue(statusCode == 200)
            XCTAssertNotNil(data)
            
            var dictionary: [String : String]
            do {
                let dictionaryData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
                if let d = dictionaryData as? [String : String] {
                    dictionary = d
                } else {
                    XCTFail()
                    return
                }
            } catch {
                print(error)
                XCTFail()
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
    
    func testIPv6DNSError() {
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
    }
}
