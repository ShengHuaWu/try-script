import Composable

// TODO: There must be a way to reuse environemnt
struct Environment {
    var run: (CommandInput) -> Effect<Result<String, EffectError>>
    var print: (String) -> Effect<Never>
}

extension Environment {
    static let live = Environment(
        run: bash(with:),
        print: { output in
            Swift.print(output)
            
            return Effect { _ in }
    })
}

#if DEBUG
var Current = Environment.live
#else
let Current = Environment.live
#endif
