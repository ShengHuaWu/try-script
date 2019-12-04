struct Environment {
    var argumentParsingClient: () -> ArgumentParsingClient
    var commandClient: () -> CommandClient
}

extension Environment {
    static let live = Environment(
        argumentParsingClient: { ArgumentParsingClient() },
        commandClient: { CommandClient() }
    )
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
