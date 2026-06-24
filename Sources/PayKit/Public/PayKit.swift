import Foundation

// Note: there is intentionally no `enum PayKit` here. A public type named
// `PayKit` collides with the module name `PayKit`, which breaks the textual
// `.swiftinterface` emitted for binary (library-evolution) distribution. The
// single Swift + Objective-C entry point is `PYKPayKit`; Swift-only conveniences
// live in `PYKPayKit` extensions.

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
