import XCTest
@testable import PayKit

private final class FakeWeChatNativeClient: WeChatNativePaying {
    var capturedRequest: NativeWeChatPayRequest?
    var result: NativeLaunchResult = .accepted()

    func launchPayment(request: NativeWeChatPayRequest, config: PYKWechatConfig?) -> NativeLaunchResult {
        capturedRequest = request
        return result
    }
}

private final class FakeAlipayNativeClient: AlipayNativePaying {
    var capturedRequest: NativeAlipayPayRequest?
    var result: NativeLaunchResult = .accepted()

    func launchPayment(
        request: NativeAlipayPayRequest,
        config: PYKAlipayConfig?,
        callback: @escaping (NativeAlipayPayResult) -> Void
    ) -> NativeLaunchResult {
        capturedRequest = request
        return result
    }
}

final class ChannelAdapterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        PYKPayKit.resetForTesting()
    }

    override func tearDown() {
        PYKPayKit.resetForTesting()
        super.tearDown()
    }

    func testWechatAdapterLaunchesNativeRequestAndCompletesFromCallbackOnce() {
        let client = FakeWeChatNativeClient()
        PYKPayKit.setWeChatNativeClientForTesting(client)
        let request = PYKWechatPayRequest(
            appId: "wx",
            partnerId: "partner",
            prepayId: "prepay",
            packageValue: "Sign=WXPay",
            nonceStr: "nonce",
            timeStamp: "123",
            sign: "sign"
        )
        var results: [PYKPayResult] = []

        PYKPayKit.pay(request: request) { result in
            results.append(result)
        }

        XCTAssertEqual(client.capturedRequest?.appId, "wx")
        XCTAssertEqual(client.capturedRequest?.packageValue, "Sign=WXPay")
        XCTAssertTrue(results.isEmpty)

        let handled = PYKPayKit.handleOpenURL(URL(string: "paykit://paykit-wechat?errCode=0&errStr=ok")!)
        let handledAgain = PYKPayKit.handleOpenURL(URL(string: "paykit://paykit-wechat?errCode=-2&errStr=cancel")!)

        XCTAssertTrue(handled)
        XCTAssertFalse(handledAgain)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.status, .success)
        XCTAssertEqual(results.first?.rawCode, "0")
    }

    func testWechatResultMapping() {
        XCTAssertEqual(WeChatPayAdapter.map(response: NativeWeChatPayResponse(errCode: 0, errStr: nil)).status, .success)
        XCTAssertEqual(WeChatPayAdapter.map(response: NativeWeChatPayResponse(errCode: -2, errStr: nil)).status, .cancelled)
        XCTAssertEqual(WeChatPayAdapter.map(response: NativeWeChatPayResponse(errCode: -1, errStr: "failed")).status, .failed)
    }

    func testAlipayAdapterLaunchesNativeRequestAndCompletesFromCallbackOnce() {
        let client = FakeAlipayNativeClient()
        PYKPayKit.setAlipayNativeClientForTesting(client)
        let request = PYKAlipayPayRequest(orderString: "order=demo", appScheme: "paykit")
        var results: [PYKPayResult] = []

        PYKPayKit.pay(request: request) { result in
            results.append(result)
        }

        XCTAssertEqual(client.capturedRequest?.orderString, "order=demo")
        XCTAssertEqual(client.capturedRequest?.appScheme, "paykit")
        XCTAssertTrue(results.isEmpty)

        let handled = PYKPayKit.handleOpenURL(URL(string: "paykit://paykit-alipay?resultStatus=6001&memo=cancel")!)
        let handledAgain = PYKPayKit.handleOpenURL(URL(string: "paykit://paykit-alipay?resultStatus=9000&memo=ok")!)

        XCTAssertTrue(handled)
        XCTAssertFalse(handledAgain)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.status, .cancelled)
        XCTAssertEqual(results.first?.rawCode, "6001")
    }

    func testAlipayResultMapping() {
        XCTAssertEqual(AlipayAdapter.map(nativeResult: NativeAlipayPayResult(resultStatus: "9000", memo: nil, result: nil)).status, .success)
        XCTAssertEqual(AlipayAdapter.map(nativeResult: NativeAlipayPayResult(resultStatus: "6001", memo: nil, result: nil)).status, .cancelled)
        XCTAssertEqual(AlipayAdapter.map(nativeResult: NativeAlipayPayResult(resultStatus: "4000", memo: "failed", result: nil)).status, .failed)
    }

    func testUnavailableNativeClientsReturnFailed() {
        PYKPayKit.setup(wechat: PYKWechatConfig(appId: "wx", universalLink: "https://example.com/"), alipay: nil)
        let request = PYKWechatPayRequest(
            appId: "wx",
            partnerId: "partner",
            prepayId: "prepay",
            packageValue: "Sign=WXPay",
            nonceStr: "nonce",
            timeStamp: "123",
            sign: "sign"
        )
        var result: PYKPayResult?

        PYKPayKit.pay(request: request) { payResult in
            result = payResult
        }

        XCTAssertEqual(result?.status, .failed)
        XCTAssertEqual(result?.rawCode, "wechat_native_unavailable")
    }
}
