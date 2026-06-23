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
}
