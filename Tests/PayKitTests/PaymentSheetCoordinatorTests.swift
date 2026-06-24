import XCTest
@testable import PayKit

final class PaymentSheetCoordinatorTests: XCTestCase {
    private func wechatRequest() -> PYKWechatPayRequest {
        PYKWechatPayRequest(
            appId: "wx",
            partnerId: "p",
            prepayId: "prepay",
            packageValue: "Sign=WXPay",
            nonceStr: "n",
            timeStamp: "1700000000",
            sign: "s"
        )
    }

    func testSelectingChannelReusesPayWithProvidedRequest() {
        let request = wechatRequest()
        var paidRequest: PYKPayRequest?
        var finalResult: PYKPayResult?

        let coordinator = PaymentSheetCoordinator(
            requestProvider: { channel, completion in
                XCTAssertEqual(channel, .wechat)
                completion(request, nil)
            },
            pay: { req, completion in
                paidRequest = req
                completion(PYKPayResult.success(channel: .wechat, rawCode: "0"))
            },
            completion: { finalResult = $0 }
        )

        coordinator.didSelect(channel: .wechat)

        XCTAssertTrue(paidRequest === request)
        XCTAssertEqual(finalResult?.status, .success)
        XCTAssertEqual(finalResult?.channel, .wechat)
    }

    func testProviderErrorReturnsFailedAndSkipsPay() {
        var payCalled = false
        var finalResult: PYKPayResult?
        let coordinator = PaymentSheetCoordinator(
            requestProvider: { _, completion in
                completion(nil, NSError(domain: "demo", code: 1))
            },
            pay: { _, _ in payCalled = true },
            completion: { finalResult = $0 }
        )

        coordinator.didSelect(channel: .alipay)

        XCTAssertFalse(payCalled)
        XCTAssertEqual(finalResult?.status, .failed)
        XCTAssertEqual(finalResult?.error?.code, "request_provider_failed")
    }

    func testProviderNilRequestReturnsFailed() {
        var finalResult: PYKPayResult?
        let coordinator = PaymentSheetCoordinator(
            requestProvider: { _, completion in completion(nil, nil) },
            pay: { _, _ in XCTFail("pay must not be called") },
            completion: { finalResult = $0 }
        )

        coordinator.didSelect(channel: .alipay)

        XCTAssertEqual(finalResult?.status, .failed)
        XCTAssertEqual(finalResult?.error?.code, "request_provider_empty")
    }

    func testChannelMismatchReturnsFailedAndSkipsPay() {
        var payCalled = false
        var finalResult: PYKPayResult?
        let coordinator = PaymentSheetCoordinator(
            requestProvider: { _, completion in
                // Selected alipay but provided a WeChat request.
                completion(self.wechatRequest(), nil)
            },
            pay: { _, _ in payCalled = true },
            completion: { finalResult = $0 }
        )

        coordinator.didSelect(channel: .alipay)

        XCTAssertFalse(payCalled)
        XCTAssertEqual(finalResult?.status, .failed)
        XCTAssertEqual(finalResult?.error?.code, "request_channel_mismatch")
    }

    func testCancelReturnsCancelledWithoutCallingProviderOrPay() {
        var providerCalled = false
        var finalResult: PYKPayResult?
        let coordinator = PaymentSheetCoordinator(
            requestProvider: { _, _ in providerCalled = true },
            pay: { _, _ in XCTFail("pay must not be called") },
            completion: { finalResult = $0 }
        )

        coordinator.didCancel()

        XCTAssertFalse(providerCalled)
        XCTAssertEqual(finalResult?.status, .cancelled)
        XCTAssertEqual(finalResult?.rawCode, "paykit_sheet_cancelled")
    }

    func testCompletionIsDeliveredOnlyOnce() {
        var count = 0
        let coordinator = PaymentSheetCoordinator(
            requestProvider: { _, completion in
                completion(self.wechatRequest(), nil)
            },
            pay: { _, completion in
                completion(PYKPayResult.success(channel: .wechat))
                completion(PYKPayResult.success(channel: .wechat))
            },
            completion: { _ in count += 1 }
        )

        coordinator.didSelect(channel: .wechat)
        coordinator.didCancel()

        XCTAssertEqual(count, 1)
    }

    func testStandardConfigurationOffersWechatAndAlipay() {
        let config = PYKPaymentSheetConfiguration.standard(amountText: "¥ 0.01")
        XCTAssertEqual(config.amountText, "¥ 0.01")
        XCTAssertEqual(config.options.map { $0.channel }, [.wechat, .alipay])
        XCTAssertEqual(config.confirmTitle, "确认支付")
    }
}
