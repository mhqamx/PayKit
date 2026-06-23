import Foundation

@objcMembers
@objc(PYKAlipayConfig)
public final class PYKAlipayConfig: NSObject {
    public let appScheme: String

    public init(appScheme: String) {
        self.appScheme = appScheme
        super.init()
    }
}
