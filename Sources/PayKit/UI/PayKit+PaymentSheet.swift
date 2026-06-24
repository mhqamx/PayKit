#if canImport(UIKit)
import UIKit

extension PYKPayKit {
    /// Active coordinators are retained here for the duration of the flow so the
    /// async request-provider / pay callbacks survive the sheet being dismissed.
    private static var activeCoordinators: [PaymentSheetCoordinator] = []

    /// Story 5.2 — Objective-C-visible standard payment sheet entry point.
    ///
    /// Presents the SDK bottom sheet, asks `requestProvider` for a matching
    /// `PYKPayRequest` once a channel is chosen, then reuses the shared pay path
    /// and reports a normalized `PYKPayResult`. The integrator still owns order
    /// creation and parameter sourcing; final order truth is the backend's.
    @objc(presentPaymentSheetFromViewController:configuration:requestProvider:completion:)
    public static func presentPaymentSheet(
        from viewController: UIViewController,
        configuration: PYKPaymentSheetConfiguration,
        requestProvider: @escaping (PYKPayChannel, @escaping (PYKPayRequest?, Error?) -> Void) -> Void,
        completion: @escaping (PYKPayResult) -> Void
    ) {
        var coordinatorRef: PaymentSheetCoordinator?
        let release: (PYKPayResult) -> Void = { result in
            if let coordinator = coordinatorRef {
                activeCoordinators.removeAll { $0 === coordinator }
            }
            completion(result)
        }

        let coordinator = PaymentSheetCoordinator(requestProvider: requestProvider, completion: release)
        coordinatorRef = coordinator
        activeCoordinators.append(coordinator)

        let sheet = PYKPaymentSheetViewController(
            configuration: configuration,
            onConfirm: { channel in coordinator.didSelect(channel: channel) },
            onCancel: { coordinator.didCancel() }
        )
        viewController.present(sheet, animated: false)
    }
}

public extension PayKit {
    /// Swift wrapper over the Objective-C-visible base (AD-1). Uses a `Result`
    /// request provider for Swift ergonomics without forking behavior.
    static func presentPaymentSheet(
        from viewController: UIViewController,
        configuration: PYKPaymentSheetConfiguration = .standard(),
        requestProvider: @escaping (PYKPayChannel, @escaping (Result<PYKPayRequest, Error>) -> Void) -> Void,
        completion: @escaping (PYKPayResult) -> Void
    ) {
        PYKPayKit.presentPaymentSheet(
            from: viewController,
            configuration: configuration,
            requestProvider: { channel, objcCompletion in
                requestProvider(channel) { result in
                    switch result {
                    case .success(let request):
                        objcCompletion(request, nil)
                    case .failure(let error):
                        objcCompletion(nil, error)
                    }
                }
            },
            completion: completion
        )
    }
}
#endif
