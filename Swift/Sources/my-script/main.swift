import Foundation
import TSCUtility // External dependencies
import MyLib1 // Local dependencies

justAFunction() // This is from `MyLib1`

struct ShellState {
    // TODO: Treat `parser` as a dependency
    let parser = ArgumentParser(commandName: "my-script", usage: "argument parsing & more ...", overview: "This is a testing script ✌️")
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
}

extension ShellState {
    var argumentParsing: ArgumentParsingState {
        set {
            enableOption = newValue.enableOption
            inputOption = newValue.inputOption
        }
        
        get {
            ArgumentParsingState(parser: parser, enableOption: enableOption, inputOption: inputOption)
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

// Store setup
let shellReducer: Reducer<ShellState, ShellAction> = combine(
    pullback(argumentParsingReducer, value: \.argumentParsing, action: \.argumentParsing),
    pullback(fileReducer, value: \.file, action: \.file)
)
let store = Store<ShellState, ShellAction>(initialState: ShellState(), reducer: shellReducer)

// Actual shell script
store.send(.argumentParsing(.setUp))
store.send(.argumentParsing(.parse))
store.send(.file(.createDir))
store.send(.file(.createFile))
store.send(.file(.insertTextToNewFile))
store.send(.file(.showContentOfNewFile))
store.send(.file(.listFiles))
store.send(.file(.removeAllFiles))
store.send(.file(.listFiles))
store.send(.file(.removeDir))
