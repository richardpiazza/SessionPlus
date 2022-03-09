import XCTest
@testable import SessionPlus

final class ClientTests: XCTestCase {
    
    let emulatedClient = EmulatedClient()
    var client: Client { emulatedClient }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    func testPerformRequestAsync() throws {
        
    }
    
    func testPerformRequestPublisher() throws {
        
    }
    
    func testPerformRequest() throws {
        
    }
}
