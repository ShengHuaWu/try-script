import TSCUtility

// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/
struct ArgumentParsingState {
    let parser = ArgumentParser(commandName: "my-script", usage: "argument parsing & more ...", overview: "This is a testing script ✌️")
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
            { _ in
                print(enableOutput)
            },
            { _ in
                print(inputOutput)
            }
        ]
    }
}
