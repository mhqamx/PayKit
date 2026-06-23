import Foundation

@objcMembers
@objc(PYKPayRequest)
open class PYKPayRequest: NSObject {
    public let channel: PYKPayChannel

    public init(channel: PYKPayChannel) {
        self.channel = channel
        super.init()
    }
}
