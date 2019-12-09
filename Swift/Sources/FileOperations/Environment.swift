import Composable

// TODO: There must be a way to reuse environemnt
struct Environment {
    // TODO: Create a new type containing all parameters
    var runCommand: (String, [String], String) -> Effect<FileAction>
}

extension Environment {
    static let live = Environment(
        runCommand: { command, arguments, path in
        return CommandClient().run(command: command, arguments: arguments, at: path).map { result in
            switch result {
            case let .success(output):
                return .print(output)
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
