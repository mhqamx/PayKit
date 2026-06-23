import XCTest
@testable import PayKit

final class PYKPublicTypesTests: XCTestCase {
    func testConfigsAreObjectiveCCompatibleObjects() {
        let wechat = PYKWechatConfig(appId: "wx-app-id", universalLink: "https://example.com/pay/")
        XCTAssertEqual(NSStringFromClass(type(of: wechat)), "PYKWechatConfig")
        XCTAssertEqual(wechat.appId, "wx-app-id")
        XCTAssertEqual(wechat.universalLink, "https://example.com/pay/")

        let alipay = PYKAlipayConfig(appScheme: "paykit-demo")
        XCTAssertEqual(NSStringFromClass(type(of: alipay)), "PYKAlipayConfig")
        XCTAssertEqual(alipay.appScheme, "paykit-demo")
    }

    func testRequestResultAndErrorModelsUseObjCCompatibleShapes() {
        let request = PYKPayRequest(channel: .wechat)
        XCTAssertEqual(NSStringFromClass(type(of: request)), "PYKPayRequest")
        XCTAssertEqual(request.channel, .wechat)

        let error = PYKPayError(code: "validation_failed", message: "Missing appId")
        let result = PYKPayResult(
            status: .failed,
            channel: .wechat,
            error: error,
            rawCode: "1001",
            rawMessage: "Missing appId"
        )

        XCTAssertEqual(NSStringFromClass(type(of: error)), "PYKPayError")
        XCTAssertEqual(NSStringFromClass(type(of: result)), "PYKPayResult")
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.channel, .wechat)
        XCTAssertEqual(result.error?.code, "validation_failed")
        XCTAssertEqual(result.rawCode, "1001")
        XCTAssertEqual(result.rawMessage, "Missing appId")
    }

    func testFacadeBaseSymbolExists() {
        let facade = PYKPayKit()
        XCTAssertEqual(NSStringFromClass(type(of: facade)), "PYKPayKit")
    }
}
