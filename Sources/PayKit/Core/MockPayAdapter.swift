import Foundation

final class MockPayAdapter: PayAdapter {
    let channel: PYKPayChannel
    private let result: PYKPayResult

    init(result: PYKPayResult, channel: PYKPayChannel = .mock) {
        self.result = result
        self.channel = channel
    }

    func startPayment(request: PYKPayRequest, completion: @escaping PYKPayCompletion) {
        completion(result)
    }

    func handleOpenURL(_ url: URL) -> Bool {
        false
    }
}
