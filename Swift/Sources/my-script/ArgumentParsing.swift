// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/
struct ArgumentParsingState {}

enum ArgumentParsingAction {
    case parse
}

let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
    switch action {
    case .parse:
        let effect: Effect<ArgumentParsingAction> = Current.argumentParsingClient().parse().fireAndForget()
        
        return [effect]
    }
}
