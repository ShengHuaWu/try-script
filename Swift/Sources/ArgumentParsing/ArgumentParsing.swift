import Composable

public struct ArgumentParsingState {
    public var isEnabled: Bool
    public var inputDir: String?
    public var exitMessage: String?
    
    public init(isEnabled: Bool, inputDir: String?, exitMessage: String?) {
        self.isEnabled = isEnabled
        self.inputDir = inputDir
        self.exitMessage = exitMessage
    }
}

public typealias ParsingResult = (isEnabled: Bool, inputDir: String?)

public enum ArgumentParsingAction {
    case parse
    case setParsingResult(ParsingResult)
    case exit(String)
}

public let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
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
        
    case let .exit(message):
        state.exitMessage = message
        
        return []
    }
}
