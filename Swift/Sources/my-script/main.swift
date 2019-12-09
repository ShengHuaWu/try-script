import Composable
import ArgumentParsing
import FileOperations

struct ShellState {
    var isEnabled = false
    var inputDir: String?
    var exitMessage: String?
}

extension ShellState {
    var argumentParsing: ArgumentParsingState {
        set {
            isEnabled = newValue.isEnabled
            inputDir = newValue.inputDir
            exitMessage = newValue.exitMessage
        }
        
        get {
            ArgumentParsingState(isEnabled: isEnabled, inputDir: inputDir, exitMessage: exitMessage)
        }
    }
    
    var file: FileState {
        set {
            exitMessage = newValue.exitMessage
        }
        
        get {
            FileState(exitMessage: exitMessage)
        }
    }
}

enum ShellAction {
    case argumentParsing(ArgumentParsingAction)
    case file(FileAction)
    // TODO: More actions
}

extension ShellAction {
    var argumentParsing: ArgumentParsingAction? {
        get {
            guard case let .argumentParsing(value) = self else { return nil }
            return value
        }
        
        set {
            guard case .argumentParsing = self, let value = newValue else { return }
            self = .argumentParsing(value)
        }
    }
    
    var file: FileAction? {
        get {
            guard case let .file(value) = self else { return nil }
            return value
        }
        
        set {
            guard case .file = self, let value = newValue else { return }
            self = .file(value)
        }
    }
}

func exitOnError(_ reducer: @escaping Reducer<ShellState, ShellAction>) -> Reducer<ShellState, ShellAction> {
    return { state, action in
        let effects = reducer(&state, action)
        if let message = state.exitMessage, !message.isEmpty {
            return [
                Effect { _ in fatalError("😱 Exit script because of \(message) ") }
            ]
        }
        
        return effects
    }
}

// Store initiative
let shellReducer: Reducer<ShellState, ShellAction> = logging(
    exitOnError(
        combine(
            pullback(argumentParsingReducer, value: \.argumentParsing, action: \.argumentParsing),
            pullback(fileReducer, value: \.file, action: \.file)
        )
    )
)
let store = Store<ShellState, ShellAction>(initialState: ShellState(), reducer: shellReducer)

// Actual shell script
[
    .argumentParsing(.parse),
    .file(.createDir),
    .file(.createFile),
    .file(.insertTextToNewFile),
    .file(.showContentOfNewFile),
    .file(.listFiles),
    .file(.removeAllFiles),
    .file(.listFiles),
    .file(.removeDir)
].forEach(store.send)
