struct ArgumentParsingState {}

enum ArgumentParsingAction {
    case parse
}

let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
    switch action {
    case .parse:
        // TODO: Save parse results
        return [
            Current.argumentParsingClient()
            .parse()
            .fireAndForget()
        ]
    }
}
