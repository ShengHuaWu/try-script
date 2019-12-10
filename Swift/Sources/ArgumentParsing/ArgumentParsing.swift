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

public enum ArgumentParsingAction {
    case parse
    case setParsingResult(ParsingResult)
    case exit(String)
}

public let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
    switch action {
    case .parse:
        return [ Current.parseArguments().handleParsingResult() ]
        
    case let .setParsingResult(result):
        state.isEnabled = result.isEnabled
        state.inputDir = result.inputDir
        
        return []
        
    case let .exit(message):
        state.exitMessage = message
        
        return []
    }
}

extension Effect where A == Result<ParsingResult, EffectError> {
    func handleParsingResult() -> Effect<ArgumentParsingAction> {
        return map { result in
            switch result {
            case let .success(result):
                return .setParsingResult(result)
            case let .failure(error):
                return .exit(error.message)
            }
        }
    }
}
