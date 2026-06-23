import Foundation

public enum PayKit {
    public static func setup(wechat: PYKWechatConfig?, alipay: PYKAlipayConfig?) {
        PYKPayKit.setup(wechat: wechat, alipay: alipay)
    }

    public static func pay(request: PYKPayRequest, completion: @escaping (PYKPayResult) -> Void) {
        PYKPayKit.pay(request: request, completion: completion)
    }

    public static func handleOpenURL(_ url: URL) -> Bool {
        PYKPayKit.handleOpenURL(url)
    }

    public static func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        PYKPayKit.handleUserActivity(userActivity)
    }
}

public enum PayKitResult {
    case success(PYKPayResult)
    case cancelled(PYKPayResult)
    case failed(PYKPayResult)

    public init(_ result: PYKPayResult) {
        switch result.status {
        case .success:
            self = .success(result)
        case .cancelled:
            self = .cancelled(result)
        case .failed:
            self = .failed(result)
        @unknown default:
            self = .failed(result)
        }
    }

    public var status: PYKPayStatus {
        switch self {
        case .success:
            return .success
        case .cancelled:
            return .cancelled
        case .failed:
            return .failed
        }
    }

    public var result: PYKPayResult {
        switch self {
        case .success(let result), .cancelled(let result), .failed(let result):
            return result
        }
    }
}
