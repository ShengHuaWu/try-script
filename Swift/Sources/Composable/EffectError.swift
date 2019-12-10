// TODO: Move this to one standalone module?
public struct EffectError: Error {
    public let message: String
}

extension EffectError: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.message = value
    }
}

extension EffectError: ExpressibleByStringInterpolation {}
