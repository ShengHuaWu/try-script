struct Environment {
    var argumentParsingClient: () -> ArgumentParsingClient
}

extension Environment {
    static let live = Environment(argumentParsingClient: { ArgumentParsingClient() })
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
