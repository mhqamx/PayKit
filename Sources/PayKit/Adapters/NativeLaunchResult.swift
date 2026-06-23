struct NativeLaunchResult {
    let accepted: Bool
    let rawCode: String
    let rawMessage: String

    static func accepted() -> NativeLaunchResult {
        NativeLaunchResult(accepted: true, rawCode: "accepted", rawMessage: "Accepted by native SDK.")
    }

    static func failed(rawCode: String, rawMessage: String) -> NativeLaunchResult {
        NativeLaunchResult(accepted: false, rawCode: rawCode, rawMessage: rawMessage)
    }
}
