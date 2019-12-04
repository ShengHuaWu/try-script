struct ArgumentParsingState {}

enum ArgumentParsingAction {
    case parse
}

let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
    switch action {
    case .parse:        
        return [
            Current.argumentParsingClient()
            .parse()
            .fireAndForget()
        ]
    }
}
