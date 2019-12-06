struct Environment {
    var commandClient: () -> CommandClient
}

extension Environment {
    static let live = Environment(commandClient: { CommandClient() })
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
