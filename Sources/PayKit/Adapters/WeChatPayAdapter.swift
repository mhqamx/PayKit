import Foundation
import ObjectiveC.runtime

struct NativeWeChatPayRequest: Equatable {
    let appId: String
    let partnerId: String
    let prepayId: String
    let packageValue: String
    let nonceStr: String
    let timeStamp: String
    let sign: String
}

struct NativeWeChatPayResponse {
    let errCode: Int
    let errStr: String?
}

protocol WeChatNativePaying {
    func launchPayment(request: NativeWeChatPayRequest, config: PYKWechatConfig?) -> NativeLaunchResult
}

struct DynamicWeChatNativeClient: WeChatNativePaying {
    func launchPayment(request: NativeWeChatPayRequest, config: PYKWechatConfig?) -> NativeLaunchResult {
        guard let requestClass = NSClassFromString("PayReq") as? NSObject.Type,
              let apiClass = NSClassFromString("WXApi") else {
            return .failed(rawCode: "wechat_native_unavailable", rawMessage: "WechatOpenSDK is not integrated.")
        }
        guard let timeStamp = UInt32(request.timeStamp) else {
            return .failed(rawCode: "wechat_invalid_timestamp", rawMessage: "WeChat timeStamp must fit UInt32.")
        }

        let nativeRequest = requestClass.init()
        nativeRequest.setValue(request.partnerId, forKey: "partnerId")
        nativeRequest.setValue(request.prepayId, forKey: "prepayId")
        nativeRequest.setValue(request.packageValue, forKey: "package")
        nativeRequest.setValue(request.nonceStr, forKey: "nonceStr")
        nativeRequest.setValue(NSNumber(value: timeStamp), forKey: "timeStamp")
        nativeRequest.setValue(request.sign, forKey: "sign")

        registerAppIfPossible(apiClass: apiClass, appId: request.appId, universalLink: config?.universalLink)
        return send(apiClass: apiClass, request: nativeRequest)
    }

    static func handleOpenURL(_ url: URL, delegate: AnyObject) -> Bool? {
        guard let apiClass = NSClassFromString("WXApi") else {
            return nil
        }
        let selector = NSSelectorFromString("handleOpenURL:delegate:")
        guard let method = class_getClassMethod(apiClass, selector) else {
            return nil
        }
        typealias HandleOpenURL = @convention(c) (AnyClass, Selector, NSURL, AnyObject) -> ObjCBool
        let implementation = method_getImplementation(method)
        let handle = unsafeBitCast(implementation, to: HandleOpenURL.self)
        return handle(apiClass, selector, url as NSURL, delegate).boolValue
    }

    private func registerAppIfPossible(apiClass: AnyClass, appId: String, universalLink: String?) {
        let selector = NSSelectorFromString("registerApp:universalLink:")
        guard let method = class_getClassMethod(apiClass, selector) else {
            return
        }
        typealias RegisterApp = @convention(c) (AnyClass, Selector, NSString, NSString) -> ObjCBool
        let implementation = method_getImplementation(method)
        let register = unsafeBitCast(implementation, to: RegisterApp.self)
        _ = register(apiClass, selector, appId as NSString, (universalLink ?? "") as NSString)
    }

    private func send(apiClass: AnyClass, request: NSObject) -> NativeLaunchResult {
        let selector = NSSelectorFromString("sendReq:")
        guard let method = class_getClassMethod(apiClass, selector) else {
            return .failed(rawCode: "wechat_send_unavailable", rawMessage: "WXApi sendReq: is not available.")
        }
        typealias SendReq = @convention(c) (AnyClass, Selector, NSObject) -> ObjCBool
        let implementation = method_getImplementation(method)
        let sendReq = unsafeBitCast(implementation, to: SendReq.self)
        guard sendReq(apiClass, selector, request).boolValue else {
            return .failed(rawCode: "wechat_send_rejected", rawMessage: "WXApi rejected the payment request.")
        }
        return .accepted()
    }
}

final class WeChatPayAdapter: NSObject, PayAdapter {
    let channel: PYKPayChannel = .wechat
    private let config: PYKWechatConfig?
    private let nativeClient: WeChatNativePaying

    init(config: PYKWechatConfig?, nativeClient: WeChatNativePaying = DynamicWeChatNativeClient()) {
        self.config = config
        self.nativeClient = nativeClient
        super.init()
    }

    func startPayment(request: PYKPayRequest, completion: @escaping PYKPayCompletion) {
        guard let request = request as? PYKWechatPayRequest else {
            completion(PYKPayResult.failure(channel: .wechat, code: "invalid_request", message: "Expected PYKWechatPayRequest."))
            return
        }
        let nativeRequest = NativeWeChatPayRequest(
            appId: request.appId,
            partnerId: request.partnerId,
            prepayId: request.prepayId,
            packageValue: request.packageValue,
            nonceStr: request.nonceStr,
            timeStamp: request.timeStamp,
            sign: request.sign
        )
        PayCallbackRouter.shared.setPending(adapter: self, completion: completion)
        let launchResult = nativeClient.launchPayment(request: nativeRequest, config: config)
        guard launchResult.accepted else {
            PayCallbackRouter.shared.complete(
                result:
                PYKPayResult.failure(
                    channel: .wechat,
                    code: "launch_failed",
                    message: launchResult.rawMessage,
                    rawCode: launchResult.rawCode
                )
            )
            return
        }
    }

    func handleOpenURL(_ url: URL) -> Bool {
        if DynamicWeChatNativeClient.handleOpenURL(url, delegate: self) == true {
            return true
        }
        guard let response = NativeWeChatPayResponse(url: url) else {
            return false
        }
        return complete(response: response)
    }

    func complete(response: NativeWeChatPayResponse) -> Bool {
        PayCallbackRouter.shared.complete(result: Self.map(response: response))
    }

    static func map(response: NativeWeChatPayResponse) -> PYKPayResult {
        let rawCode = String(response.errCode)
        switch response.errCode {
        case 0:
            return .success(channel: .wechat, rawCode: rawCode, rawMessage: response.errStr)
        case -2:
            return .cancelled(channel: .wechat, rawCode: rawCode, rawMessage: response.errStr)
        default:
            return .failure(
                channel: .wechat,
                code: "wechat_failed",
                message: response.errStr ?? "WeChat payment failed.",
                rawCode: rawCode
            )
        }
    }

    @objc(onResp:)
    func onResp(_ response: NSObject) {
        let errCode = (response.value(forKey: "errCode") as? NSNumber)?.intValue ?? -1
        let errStr = response.value(forKey: "errStr") as? String
        _ = complete(response: NativeWeChatPayResponse(errCode: Int(errCode), errStr: errStr))
    }
}

private extension NativeWeChatPayResponse {
    init?(url: URL) {
        guard url.host == "paykit-wechat" else {
            return nil
        }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard let codeString = items.first(where: { $0.name == "errCode" })?.value,
              let code = Int(codeString) else {
            return nil
        }
        self.init(errCode: code, errStr: items.first(where: { $0.name == "errStr" })?.value)
    }
}
