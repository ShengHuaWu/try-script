import Composable

// TODO: There must be a way to reuse environemnt
struct Environment {
    var run: (CommandInput) -> Effect<FileAction>
    var print: (String) -> Effect<Never>
}

extension Environment {
    static let live = Environment(
        run: { input in
            // TODO: Move this to `Effect` extension
            return bash(with: input).map { result in
                switch result {
                case let .success(output):
                    return .print(output)
                case let .failure(error):
                    return .exit(error.message)
                }
            }
    }, print: { output in
        Swift.print(output)
        
        return Effect { _ in }
    })
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
