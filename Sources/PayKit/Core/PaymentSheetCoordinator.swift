import Foundation

/// Orchestrates the standard payment sheet flow (Story 5.2) independent of any
/// UIKit presentation, so the channel→provider→validate→pay→result pipeline is
/// unit testable. The UI layer drives it through `didSelect` / `didCancel`.
///
/// Responsibilities:
/// - After a channel is selected, ask the integrator for a matching request.
/// - Reject nil / errored / channel-mismatched requests with a `failed` result,
///   without ever calling the native adapters.
/// - For valid requests, reuse the shared pay entry point so results stay
///   normalized to `PYKPayResult` (AD-1, AD-5) — no second payment path.
/// - Deliver the final result at most once.
final class PaymentSheetCoordinator {
    typealias ObjCRequestCompletion = (PYKPayRequest?, Error?) -> Void
    typealias RequestProvider = (PYKPayChannel, @escaping ObjCRequestCompletion) -> Void
    typealias PayFunction = (PYKPayRequest, @escaping (PYKPayResult) -> Void) -> Void

    private let requestProvider: RequestProvider
    private let pay: PayFunction
    private var completion: ((PYKPayResult) -> Void)?

    init(
        requestProvider: @escaping RequestProvider,
        pay: @escaping PayFunction = { PYKPayKit.pay(request: $0, completion: $1) },
        completion: @escaping (PYKPayResult) -> Void
    ) {
        self.requestProvider = requestProvider
        self.pay = pay
        self.completion = completion
    }

    func didSelect(channel: PYKPayChannel) {
        requestProvider(channel) { [weak self] request, error in
            self?.handleProvided(channel: channel, request: request, error: error)
        }
    }

    func didCancel() {
        finish(
            PYKPayResult.cancelled(
                channel: .unknown,
                rawCode: "paykit_sheet_cancelled",
                rawMessage: "User dismissed the payment sheet."
            )
        )
    }

    private func handleProvided(channel: PYKPayChannel, request: PYKPayRequest?, error: Error?) {
        if let error = error {
            finish(
                PYKPayResult.failure(
                    channel: channel,
                    code: "request_provider_failed",
                    message: error.localizedDescription,
                    rawCode: "paykit_request_provider_failed"
                )
            )
            return
        }
        guard let request = request else {
            finish(
                PYKPayResult.failure(
                    channel: channel,
                    code: "request_provider_empty",
                    message: "Request provider returned no request for the selected channel.",
                    rawCode: "paykit_request_provider_empty"
                )
            )
            return
        }
        guard request.channel == channel else {
            finish(
                PYKPayResult.failure(
                    channel: channel,
                    code: "request_channel_mismatch",
                    message: "Provided request channel does not match the selected channel.",
                    rawCode: "paykit_request_channel_mismatch"
                )
            )
            return
        }
        pay(request) { [weak self] result in
            self?.finish(result)
        }
    }

    private func finish(_ result: PYKPayResult) {
        guard let completion = completion else {
            return
        }
        self.completion = nil
        completion(result)
    }
}
