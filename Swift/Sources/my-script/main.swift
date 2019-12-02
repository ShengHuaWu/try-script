import Foundation
import TSCUtility // External dependencies
import MyLib1 // Local dependencies

justAFunction() // This is from `MyLib1`

struct ShellState {
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
}

extension ShellState {
    var argumentParsingState: ArgumentParsingState {
        set {
            enableOption = newValue.enableOption
            inputOption = newValue.inputOption
        }
        
        get {
            ArgumentParsingState(enableOption: enableOption, inputOption: inputOption)
        }
    }
    
    var fileState: FileState {
        set {}
        
        get {
            FileState()
        }
    }
}

func logging(_ task: @escaping Task<ShellState>) -> Task<ShellState> {
    return { state in
        print("before everything")
        let effects = try task(&state)
        print("after everything")
        return effects
    }
}

do {
    var initialState = ShellState()
    let effects = try logging(
        combine(
            pullback(parse, \.argumentParsingState),
            pullback(file, \.fileState)
        )
        )(&initialState)
    effects.forEach { $0() }
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print("Error occurs: \n\(error.localizedDescription)")
}
