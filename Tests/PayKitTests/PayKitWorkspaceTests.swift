import XCTest
@testable import PayKit

final class PayKitWorkspaceTests: XCTestCase {
    func testWorkspaceModuleMetadata() {
        XCTAssertEqual(PayKitWorkspace.moduleName, "PayKit")
        XCTAssertEqual(PayKitWorkspace.minimumIOSDeploymentTarget, "15.0")
    }
}
