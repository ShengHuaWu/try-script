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

func logging(_ task: @escaping Task<ShellState, String>) -> Task<ShellState, String> {
    return { state in
        print("before everything")
        let outputs = try task(&state)
        outputs.forEach { print($0()) }
        print("after everything")
        return outputs
    }
}

do {
    var initialState = ShellState()
    _ = try logging(
        combine(
            pullback(parse, \.argumentParsingState),
            pullback(file, \.fileState)
        )
        )(&initialState)
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print("Error occurs: \n\(error.localizedDescription)")
}
