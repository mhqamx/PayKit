import Foundation

@objcMembers
@objc(PYKWechatConfig)
public final class PYKWechatConfig: NSObject {
    public let appId: String
    public let universalLink: String

    public init(appId: String, universalLink: String) {
        self.appId = appId
        self.universalLink = universalLink
        super.init()
    }
}
