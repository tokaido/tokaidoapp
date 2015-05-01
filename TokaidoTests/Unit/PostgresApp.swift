import XCTest

class PostgresApp: XCTestCase {
    
    func testInstallation() {
        XCTAssertTrue(TKDPostgresApp.isInstalled())
    }
    
}