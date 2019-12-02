import Foundation

// External dependencies
import TSCUtility

// Local dependencies
import MyLib1

justAFunction() // This is from `MyLib1`

// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/
do {
    let parser = ArgumentParser(commandName: "ap",
                                usage: "arguments parsing",
                                overview: "The command is used for argument parsing")
    
    let enable = parser.add(option: "--enable",
                            shortName: "-e",
                            kind: Bool.self,
                            usage: "Enable something",
                            completion: ShellCompletion.none)
    let input = parser.add(option: "--input",
                           shortName: "-i",
                           kind: String.self,
                           usage: "An input filename",
                           completion: .filename)
    
    let argsv = Array(CommandLine.arguments.dropFirst())
    let parguments = try parser.parse(argsv)
    
    if let isEnabled = parguments.get(enable) {
        print("Enabled: \(isEnabled)")
    }
    
    if let filename = parguments.get(input) {
        print("Using filename: \(filename)")
    }

} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}

// Basic functionalities
let downloadsDir = "~/Downloads"
let newTempDir = "NewTemp"
let newFile = "my-file.txt"
let newFile1 = "my-file1.txt"
let newFile2 = "my-file2.txt"
let newText = "this is a good text."

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

func tryProcess() throws {
    print(try run(command: "sh adb-run-tests.sh", arguments: ["-h"], at: "~/Development/swift-everywhere-toolchain/Platypus"))
    print(try run(command: "make", arguments: ["help"], at: "~/Development/swift-everywhere-toolchain"))
    
    print(try run(command: "mkdir", arguments: ["-p", newTempDir], at: downloadsDir))
    print(try run(command: "touch", arguments: [newFile], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "echo", arguments: [newText, ">>", newFile], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "cat", arguments: [newFile], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "ls", arguments: ["-al"], at: "\(downloadsDir)/\(newTempDir)"))
    
    print(try run(command: "cp", arguments: [newFile, newFile1], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "cat", arguments: [newFile1], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "ls", arguments: ["-al"], at: "\(downloadsDir)/\(newTempDir)"))
    
    print(try run(command: "mv", arguments: [newFile, newFile2], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "cat", arguments: [newFile2], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "ls", arguments: ["-al"], at: "\(downloadsDir)/\(newTempDir)"))
    
    print(try run(command: "rm", arguments: ["*"], at: "\(downloadsDir)/\(newTempDir)"))
    print(try run(command: "rmdir", arguments: [newTempDir], at: downloadsDir))
    print(try run(command: "ls", arguments: ["-al"], at: downloadsDir))

    print(try run(command: "python", arguments: ["--version"]))
}

do {
    try tryProcess()
} catch let error {
    print("Error occurs: \n\(error.localizedDescription)")
}
