import TSCUtility

// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/
struct ArgumentParsingState {
    let parser: ArgumentParser
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
}

enum ArgumentParsingAction {
    case setUp
    case parse
}

let argumentParsingReducer: Reducer<ArgumentParsingState, ArgumentParsingAction> = { state, action in
    switch action {
    case .setUp:
        let enable = state.parser.add(option: "--enable",
                                      shortName: "-e",
                                      kind: Bool.self,
                                      usage: "✌️ Enable something",
                                      completion: ShellCompletion.none)
        state.enableOption = enable
        
        let input = state.parser.add(option: "--input",
                                     shortName: "-i",
                                     kind: String.self,
                                     usage: "An input filename",
                                     completion: .filename)
        state.inputOption = input
        
        return []
        
    case .parse:
        let argsv = Array(CommandLine.arguments.dropFirst())
        do {
            let parguments = try state.parser.parse(argsv)
            var enableOutput = ""
            if let enable = state.enableOption, let isEnabled = parguments.get(enable) {
                enableOutput = "Enabled: \(isEnabled)"
            }
            
            var inputOutput = ""
            if let input = state.inputOption, let filename = parguments.get(input) {
                inputOutput = "Using filename: \(filename)"
            }
            
            return [
                Effect { _ in
                    print(enableOutput)
                },
                Effect { _ in
                    print(inputOutput)
                }
            ]
        // TODO: Merge throwing logic, e.g. convenient method of `Effect`
        } catch ArgumentParserError.expectedValue(let value) {
            return [
                Effect { _ in
                    print("Missing value for argument \(value).")
                }
            ]
        } catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
            return [
                Effect { _ in
                    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
                }
            ]
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
    }
}
