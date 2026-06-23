import Foundation

@objcMembers
@objc(PYKPayError)
public final class PYKPayError: NSObject {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
        super.init()
    }
}
