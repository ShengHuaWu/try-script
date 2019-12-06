// TODO: There must be a way to reuse environemnt
struct Environment {
    // TODO: Change it to a cluster of functions, instead of a class
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
