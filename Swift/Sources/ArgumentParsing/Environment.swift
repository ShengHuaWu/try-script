import Composable

struct Environment {
    var parseArguments: () -> Effect<ArgumentParsingAction>
}

extension Environment {
    static let live = Environment(parseArguments: {        
        return ArgumentParsingClient().parse().map { result in
            // TODO: Move this to `Effect` extension
            switch result {
            case let .success(result):
                return .setParsingResult(result)
            case let .failure(error):
                return .exit(error.message)
            }
        }
    })
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
