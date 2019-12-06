import Composable

public struct ArgumentParsingState {
    public var isEnabled: Bool
    public var inputDir: String?
    public var shouldExit: Bool
    
    public init(isEnabled: Bool, inputDir: String?, shouldExit: Bool) {
        self.isEnabled = isEnabled
        self.inputDir = inputDir
        self.shouldExit = shouldExit
    }
}

public typealias ParsingResult = (isEnabled: Bool, inputDir: String?)

public enum ArgumentParsingAction {
    case parse
    case setParsingResult(ParsingResult)
    case exit
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
        
    case .exit:
        state.shouldExit = true
        
        return []
    }
}
