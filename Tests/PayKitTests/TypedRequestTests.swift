import XCTest
@testable import PayKit

final class TypedRequestTests: XCTestCase {
    func testWechatRequestCarriesRequiredFieldsAndChannel() {
        let request = PYKWechatPayRequest(
            appId: "wx",
            partnerId: "partner",
            prepayId: "prepay",
            packageValue: "Sign=WXPay",
            nonceStr: "nonce",
            timeStamp: "123",
            sign: "sign"
        )

        XCTAssertEqual(request.channel, .wechat)
        XCTAssertNil(request.validationFailureResult())
        XCTAssertEqual(request.packageValue, "Sign=WXPay")
    }

    func testWechatRequestValidationFailsBeforeNativeCall() {
        let request = PYKWechatPayRequest(
            appId: "",
            partnerId: "partner",
            prepayId: "prepay",
            packageValue: "package",
            nonceStr: "nonce",
            timeStamp: "123",
            sign: "sign"
        )

        let result = request.validationFailureResult()
        XCTAssertEqual(result?.status, .failed)
        XCTAssertEqual(result?.channel, .wechat)
        XCTAssertEqual(result?.rawCode, "paykit_validation_failed")
    }

    func testAlipayRequestCarriesRequiredFieldsAndChannel() {
        let request = PYKAlipayPayRequest(orderString: "order=demo", appScheme: "paykit")

        XCTAssertEqual(request.channel, .alipay)
        XCTAssertNil(request.validationFailureResult())
        XCTAssertEqual(request.orderString, "order=demo")
        XCTAssertEqual(request.appScheme, "paykit")
    }

    func testAlipayRequestValidationFailsBeforeNativeCall() {
        let request = PYKAlipayPayRequest(orderString: "order=demo", appScheme: "")

        let result = request.validationFailureResult()
        XCTAssertEqual(result?.status, .failed)
        XCTAssertEqual(result?.channel, .alipay)
        XCTAssertEqual(result?.rawCode, "paykit_validation_failed")
    }
}
