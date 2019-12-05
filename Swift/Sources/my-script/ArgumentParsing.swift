struct ArgumentParsingState {
    var isEnabled: Bool
    var inputDir: String?
    var shouldExit: Bool
}

typealias ParsingResult = (isEnabled: Bool, inputDir: String?)

enum ArgumentParsingAction {
    case parse
    case setParsingResult(ParsingResult)
    case exit
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
        
    case .exit:
        state.shouldExit = true
        
        return []
    }
}
