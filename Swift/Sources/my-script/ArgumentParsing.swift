struct ArgumentParsingState {
    var isEnabled = false
    var inputDir: String?
}

typealias ParsingResult = (isEnabled: Bool, inputDir: String?)

enum ArgumentParsingAction {
    case parse
    case setParsingResult(ParsingResult)
}

let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
    switch action {
    case .parse:
        return [
            Current.argumentParsingClient()
            .parse()
        ]
        
    case let .setParsingResult(result):
        state.isEnabled = result.isEnabled
        state.inputDir = result.inputDir
        
        return []
    }
}
