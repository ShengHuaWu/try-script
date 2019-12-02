import Foundation

// External dependencies
import TSCUtility

// Local dependencies
import MyLib1

justAFunction() // This is from `MyLib1`

// Functional way
typealias Task<State> = (inout State) throws -> Void

func combine<State>(_ tasks: Task<State>...) -> Task<State> {
    return { state in
        try tasks.forEach { try $0(&state) }
    }
}

func pullback<GlobalState, LocalState>(_ task: @escaping Task<LocalState>, _ kp: WritableKeyPath<GlobalState, LocalState>) -> Task<GlobalState> {
    return { globalState in
        var localState = globalState[keyPath: kp]
        try task(&localState)
        globalState[keyPath: kp] = localState
    }
}

struct ShellState {
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
    var outputs: [String] = []
}

struct FileState {
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
    var outputs: [String]
}

struct ArgumentParsingState {
    let parser = ArgumentParser(commandName: "my-script", usage: "argument parsing & more ...", overview: "This is a testing script")
    var enableOption: OptionArgument<Bool>?
    var inputOption: OptionArgument<String>?
    var outputs: [String]
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

func run(command: String, arguments: [String] = [], at path: String = ".") throws -> String {
    let process = Process()
    let pipe = Pipe()
    let command = "cd \(path.replacingOccurrences(of: " ", with: "\\ ")) && \(command) \(arguments.joined(separator: " "))"
    if #available(OSX 10.13, *) {
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
    } else {
        process.launchPath = "bin/bash"
    }
    process.arguments = ["-c", command]
    process.standardOutput = pipe
    if #available(OSX 10.13, *) {
        try process.run()
    } else {
        process.launch()
    }
    process.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? "There is no output for \(command)"
}

// Basic functionalities
let customHelp: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "sh adb-run-tests.sh", arguments: ["-h"], at: "~/Development/swift-everywhere-toolchain/Platypus")
    )
}

let makeHelp: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "make", arguments: ["help"], at: "~/Development/swift-everywhere-toolchain")
    )
}

let createDir: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "mkdir", arguments: ["-p", state.newTempDir], at: state.downloadsDir)
    )
}

let createFile: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "touch", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
    )
}

let insertTextToNewFile: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "echo", arguments: [state.newText, ">>", state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
    )
}

let showContentOfNewFile: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "cat", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
    )
}

let listFiles: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
    )
}

let removeAllFiles: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "rm", arguments: ["*"], at: "\(state.downloadsDir)/\(state.newTempDir)")
    )
}

let removeDir: Task<FileState> = { state in
    state.outputs.append(
        try run(command: "rmdir", arguments: [state.newTempDir], at: state.downloadsDir)
    )
}

let file: Task<ShellState> = pullback(
    combine(
        customHelp,
        makeHelp,
        createDir,
        createFile,
        insertTextToNewFile,
        showContentOfNewFile,
        listFiles,
        removeAllFiles,
        removeDir
    ),
    \.fileState
)

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
