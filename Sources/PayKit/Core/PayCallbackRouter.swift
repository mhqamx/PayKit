import Foundation

final class PayCallbackRouter {
    static let shared = PayCallbackRouter()

    private var adapters: [PYKPayChannel: PayAdapter] = [:]
    private weak var activeAdapter: PayAdapter?
    private var pendingCompletion: PYKPayCompletion?

    private init() {}

    func register(_ adapter: PayAdapter) {
        adapters[adapter.channel] = adapter
    }

    func pay(request: PYKPayRequest, completion: @escaping PYKPayCompletion) {
        guard let adapter = adapters[request.channel] else {
            completion(
                PYKPayResult.failure(
                    channel: request.channel,
                    code: "channel_unavailable",
                    message: "No payment adapter is available for the requested channel.",
                    rawCode: "paykit_channel_unavailable"
                )
            )
            return
        }
        adapter.startPayment(request: request, completion: completion)
    }

    func setPending(adapter: PayAdapter, completion: @escaping PYKPayCompletion) {
        activeAdapter = adapter
        pendingCompletion = completion
    }

    @discardableResult
    func complete(result: PYKPayResult) -> Bool {
        guard let completion = pendingCompletion else {
            return false
        }
        pendingCompletion = nil
        activeAdapter = nil
        completion(result)
        return true
    }

    func handleOpenURL(_ url: URL) -> Bool {
        activeAdapter?.handleOpenURL(url) ?? false
    }

    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        activeAdapter?.handleUserActivity(userActivity) ?? false
    }

    func reset() {
        adapters.removeAll()
        activeAdapter = nil
        pendingCompletion = nil
    }
}
