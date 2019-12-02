import TSCUtility

struct ArgumentParsingState {
    let parser = ArgumentParser(commandName: "my-script", usage: "argument parsing & more ...", overview: "This is a testing script")
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
    var outputs: [String]
}

// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/
let setUpArgumentParsing: Task<ArgumentParsingState> = { state in
    let enable = state.parser.add(option: "--enable",
                                  shortName: "-e",
                                  kind: Bool.self,
                                  usage: "Enable something",
                                  completion: ShellCompletion.none)
    state.enableOption = enable
    
    let input = state.parser.add(option: "--input",
                                 shortName: "-i",
                                 kind: String.self,
                                 usage: "An input filename",
                                 completion: .filename)
    state.inputOption = input
}

let parseArguments: Task<ArgumentParsingState> = { state in
    let argsv = Array(CommandLine.arguments.dropFirst())
    let parguments = try state.parser.parse(argsv)
        
    if let enable = state.enableOption, let isEnabled = parguments.get(enable) {
        state.outputs.append("Enabled: \(isEnabled)")
    }
    
    if let input = state.inputOption, let filename = parguments.get(input) {
        state.outputs.append("Using filename: \(filename)")
    }
}

let parse: Task<ShellState> = pullback(
    combine(
        setUpArgumentParsing,
        parseArguments
    ),
    \.argumentParsingState
)
