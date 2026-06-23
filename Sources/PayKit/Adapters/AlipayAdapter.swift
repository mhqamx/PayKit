import Foundation
import ObjectiveC.runtime

struct NativeAlipayPayRequest: Equatable {
    let orderString: String
    let appScheme: String
}

struct NativeAlipayPayResult {
    let resultStatus: String
    let memo: String?
    let result: String?
}

protocol AlipayNativePaying {
    func launchPayment(
        request: NativeAlipayPayRequest,
        config: PYKAlipayConfig?,
        callback: @escaping (NativeAlipayPayResult) -> Void
    ) -> NativeLaunchResult
    func handleOpenURL(_ url: URL, callback: @escaping (NativeAlipayPayResult) -> Void) -> Bool
}

extension AlipayNativePaying {
    func handleOpenURL(_ url: URL, callback: @escaping (NativeAlipayPayResult) -> Void) -> Bool {
        false
    }
}

struct DynamicAlipayNativeClient: AlipayNativePaying {
    typealias CallbackBlock = @convention(block) (NSDictionary?) -> Void

    func launchPayment(
        request: NativeAlipayPayRequest,
        config: PYKAlipayConfig?,
        callback: @escaping (NativeAlipayPayResult) -> Void
    ) -> NativeLaunchResult {
        guard let service = Self.defaultService() else {
            return .failed(rawCode: "alipay_native_unavailable", rawMessage: "AlipaySDK is not integrated.")
        }
        let selector = NSSelectorFromString("payOrder:fromScheme:callback:")
        guard let method = class_getInstanceMethod(type(of: service), selector) else {
            return .failed(rawCode: "alipay_pay_order_unavailable", rawMessage: "AlipaySDK payOrder:fromScheme:callback: is not available.")
        }
        let callbackBlock: CallbackBlock = { dictionary in
            callback(NativeAlipayPayResult(dictionary: dictionary))
        }
        typealias PayOrder = @convention(c) (NSObject, Selector, NSString, NSString, CallbackBlock) -> Void
        let implementation = method_getImplementation(method)
        let payOrder = unsafeBitCast(implementation, to: PayOrder.self)
        payOrder(service, selector, request.orderString as NSString, request.appScheme as NSString, callbackBlock)
        return .accepted()
    }

    func handleOpenURL(_ url: URL, callback: @escaping (NativeAlipayPayResult) -> Void) -> Bool {
        guard let service = Self.defaultService() else {
            return false
        }
        let selector = NSSelectorFromString("processOrderWithPaymentResult:standbyCallback:")
        guard let method = class_getInstanceMethod(type(of: service), selector) else {
            return false
        }
        let callbackBlock: CallbackBlock = { dictionary in
            callback(NativeAlipayPayResult(dictionary: dictionary))
        }
        typealias ProcessOrder = @convention(c) (NSObject, Selector, NSURL, CallbackBlock) -> Void
        let implementation = method_getImplementation(method)
        let processOrder = unsafeBitCast(implementation, to: ProcessOrder.self)
        processOrder(service, selector, url as NSURL, callbackBlock)
        return true
    }

    private static func defaultService() -> NSObject? {
        guard let sdkClass = NSClassFromString("AlipaySDK") else {
            return nil
        }
        let selector = NSSelectorFromString("defaultService")
        guard let method = class_getClassMethod(sdkClass, selector) else {
            return nil
        }
        typealias DefaultService = @convention(c) (AnyClass, Selector) -> NSObject?
        let implementation = method_getImplementation(method)
        let defaultService = unsafeBitCast(implementation, to: DefaultService.self)
        return defaultService(sdkClass, selector)
    }
}

final class AlipayAdapter: PayAdapter {
    let channel: PYKPayChannel = .alipay
    private let config: PYKAlipayConfig?
    private let nativeClient: AlipayNativePaying

    init(config: PYKAlipayConfig?, nativeClient: AlipayNativePaying = DynamicAlipayNativeClient()) {
        self.config = config
        self.nativeClient = nativeClient
    }

    func startPayment(request: PYKPayRequest, completion: @escaping PYKPayCompletion) {
        guard let request = request as? PYKAlipayPayRequest else {
            completion(PYKPayResult.failure(channel: .alipay, code: "invalid_request", message: "Expected PYKAlipayPayRequest."))
            return
        }
        let scheme = request.appScheme.isEmpty ? (config?.appScheme ?? "") : request.appScheme
        let nativeRequest = NativeAlipayPayRequest(orderString: request.orderString, appScheme: scheme)
        PayCallbackRouter.shared.setPending(adapter: self, completion: completion)
        let launchResult = nativeClient.launchPayment(request: nativeRequest, config: config) { [weak self] result in
            _ = self?.complete(nativeResult: result)
        }
        guard launchResult.accepted else {
            PayCallbackRouter.shared.complete(
                result:
                PYKPayResult.failure(
                    channel: .alipay,
                    code: "launch_failed",
                    message: launchResult.rawMessage,
                    rawCode: launchResult.rawCode
                )
            )
            return
        }
    }

    func handleOpenURL(_ url: URL) -> Bool {
        if nativeClient.handleOpenURL(url, callback: { [weak self] result in
            _ = self?.complete(nativeResult: result)
        }) {
            return true
        }
        guard let result = NativeAlipayPayResult(url: url) else {
            return false
        }
        return complete(nativeResult: result)
    }

    func complete(nativeResult: NativeAlipayPayResult) -> Bool {
        PayCallbackRouter.shared.complete(result: Self.map(nativeResult: nativeResult))
    }

    static func map(nativeResult: NativeAlipayPayResult) -> PYKPayResult {
        switch nativeResult.resultStatus {
        case "9000":
            return .success(channel: .alipay, rawCode: nativeResult.resultStatus, rawMessage: nativeResult.memo)
        case "6001":
            return .cancelled(channel: .alipay, rawCode: nativeResult.resultStatus, rawMessage: nativeResult.memo)
        default:
            return .failure(
                channel: .alipay,
                code: "alipay_failed",
                message: nativeResult.memo ?? "Alipay payment failed.",
                rawCode: nativeResult.resultStatus,
                rawMessage: nativeResult.result
            )
        }
    }
}

private extension NativeAlipayPayResult {
    init(dictionary: NSDictionary?) {
        self.init(
            resultStatus: dictionary?["resultStatus"] as? String ?? "",
            memo: dictionary?["memo"] as? String,
            result: dictionary?["result"] as? String
        )
    }
}

private extension NativeAlipayPayResult {
    init?(url: URL) {
        guard url.host == "paykit-alipay" else {
            return nil
        }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard let status = items.first(where: { $0.name == "resultStatus" })?.value else {
            return nil
        }
        self.init(
            resultStatus: status,
            memo: items.first(where: { $0.name == "memo" })?.value,
            result: items.first(where: { $0.name == "result" })?.value
        )
    }
}
