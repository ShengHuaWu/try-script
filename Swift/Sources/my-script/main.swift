import Foundation
import MyLib1 // Local dependencies

justAFunction() // This is from `MyLib1`

struct ShellState {
    var isEnabled = false
    var inputDir: String?
}

extension ShellState {
    var argumentParsing: ArgumentParsingState {
        set {
            isEnabled = newValue.isEnabled
            inputDir = newValue.inputDir
        }
        
        get {
            ArgumentParsingState()
        }
    }
    
    var file: FileState {
        set {}
        
        get {
            FileState()
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

// Store initiative
let shellReducer: Reducer<ShellState, ShellAction> = logging(
    combine(
        pullback(argumentParsingReducer, value: \.argumentParsing, action: \.argumentParsing),
        pullback(fileReducer, value: \.file, action: \.file)
    )
)
let store = Store<ShellState, ShellAction>(initialState: ShellState(), reducer: shellReducer)

// Actual shell script
// TODO: Exit when any error occurs
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
