import XCTest
@testable import PayKit

final class PayKitFacadeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        PYKPayKit.resetForTesting()
    }

    override func tearDown() {
        PYKPayKit.resetForTesting()
        super.tearDown()
    }

    func testSwiftSetupDelegatesToPYKPayKitBase() {
        let wechat = PYKWechatConfig(appId: "wx-demo", universalLink: "https://example.com/pay/")
        let alipay = PYKAlipayConfig(appScheme: "paykit-demo")

        PayKit.setup(wechat: wechat, alipay: alipay)

        XCTAssertTrue(PYKPayKit.currentWechatConfig === wechat)
        XCTAssertTrue(PYKPayKit.currentAlipayConfig === alipay)
    }

    func testSwiftPayDelegatesToSharedBaseAndReturnsUnavailableFailure() {
        let request = PYKPayRequest(channel: .unknown)
        var receivedResult: PYKPayResult?

        PayKit.pay(request: request) { result in
            receivedResult = result
        }

        XCTAssertEqual(receivedResult?.status, .failed)
        XCTAssertEqual(receivedResult?.channel, .unknown)
        XCTAssertEqual(receivedResult?.error?.code, "channel_unavailable")
        XCTAssertEqual(receivedResult?.rawCode, "paykit_channel_unavailable")
    }

    func testPayKitResultProjectsPYKPayResultStatus() {
        XCTAssertEqual(PayKitResult(PYKPayResult(status: .success, channel: .wechat)).status, .success)
        XCTAssertEqual(PayKitResult(PYKPayResult(status: .cancelled, channel: .wechat)).status, .cancelled)
        XCTAssertEqual(PayKitResult(PYKPayResult(status: .failed, channel: .wechat)).status, .failed)
    }
}
