import Foundation

@objc(PYKPayChannel)
public enum PYKPayChannel: Int {
    case unknown = 0
    case wechat
    case alipay
}

@objc(PYKPayStatus)
public enum PYKPayStatus: Int {
    case success = 0
    case cancelled
    case failed
}
