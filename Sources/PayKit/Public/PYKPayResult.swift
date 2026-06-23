import Foundation

@objcMembers
@objc(PYKPayResult)
public final class PYKPayResult: NSObject {
    public let status: PYKPayStatus
    public let channel: PYKPayChannel
    public let error: PYKPayError?
    public let rawCode: String?
    public let rawMessage: String?

    public init(
        status: PYKPayStatus,
        channel: PYKPayChannel,
        error: PYKPayError? = nil,
        rawCode: String? = nil,
        rawMessage: String? = nil
    ) {
        self.status = status
        self.channel = channel
        self.error = error
        self.rawCode = rawCode
        self.rawMessage = rawMessage
        super.init()
    }

    static func success(channel: PYKPayChannel, rawCode: String? = nil, rawMessage: String? = nil) -> PYKPayResult {
        PYKPayResult(status: .success, channel: channel, rawCode: rawCode, rawMessage: rawMessage)
    }

    static func cancelled(channel: PYKPayChannel, rawCode: String? = nil, rawMessage: String? = nil) -> PYKPayResult {
        PYKPayResult(status: .cancelled, channel: channel, rawCode: rawCode, rawMessage: rawMessage)
    }

    static func failure(
        channel: PYKPayChannel,
        code: String,
        message: String,
        rawCode: String? = nil,
        rawMessage: String? = nil
    ) -> PYKPayResult {
        let error = PYKPayError(code: code, message: message)
        return PYKPayResult(
            status: .failed,
            channel: channel,
            error: error,
            rawCode: rawCode ?? code,
            rawMessage: rawMessage ?? message
        )
    }
}
