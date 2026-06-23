import Foundation

typealias PYKPayCompletion = (PYKPayResult) -> Void

protocol PayAdapter: AnyObject {
    var channel: PYKPayChannel { get }

    func startPayment(request: PYKPayRequest, completion: @escaping PYKPayCompletion)
    func handleOpenURL(_ url: URL) -> Bool
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool
}

extension PayAdapter {
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        return handleOpenURL(url)
    }
}
