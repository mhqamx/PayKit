import XCTest
@testable import PayKit

final class MockAdapterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        PYKPayKit.resetForTesting()
    }

    override func tearDown() {
        PYKPayKit.resetForTesting()
        super.tearDown()
    }

    func testMockAdapterCanReturnSuccessCancelledAndFailed() {
        for status in [PYKPayStatus.success, .cancelled, .failed] {
            let expected = PYKPayResult(status: status, channel: .mock)
            PYKPayKit.registerMockAdapterForTesting(result: expected)

            var actual: PYKPayResult?
            PayKit.pay(request: PYKPayRequest(channel: .mock)) { result in
                actual = result
            }

            XCTAssertEqual(actual?.status, status)
            XCTAssertEqual(actual?.channel, .mock)
        }
    }
}
