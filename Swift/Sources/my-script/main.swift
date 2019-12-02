import Foundation
import TSCUtility // External dependencies
import MyLib1 // Local dependencies

justAFunction() // This is from `MyLib1`

struct ShellState {
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
    var outputs: [String] = []
}

extension ShellState {
    var argumentParsingState: ArgumentParsingState {
        set {
            enableOption = newValue.enableOption
            inputOption = newValue.inputOption
            outputs += newValue.outputs
        }
        
        get {
            ArgumentParsingState(enableOption: enableOption, inputOption: inputOption, outputs: outputs)
        }
    }
    
    var fileState: FileState {
        set {
            outputs += newValue.outputs
        }
        
        get {
            FileState(outputs: outputs)
        }
    }
}

func logging(_ task: @escaping Task<ShellState>) -> Task<ShellState> {
    return { state in
        print("before everything")
        try task(&state)
        print(state.outputs)
        print("after everything")
    }
}

do {
    var initialState = ShellState()
    try logging(
        combine(
            parse,
            file
        )
        )(&initialState)
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print("Error occurs: \n\(error.localizedDescription)")
}
