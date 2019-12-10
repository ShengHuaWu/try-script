import Composable

struct Environment {
    var parseArguments: () -> Effect<Result<ParsingResult, EffectError>>
}

extension Environment {
    static let live = Environment(parseArguments: ArgumentParsingClient().parse)
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
