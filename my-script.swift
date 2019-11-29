#!/usr/bin/swift sh

import Foundation

// External dependencies
import ShellOut // @JohnSundell ~> 2.2.0

// Local dependencies
import MyLib1 // ./MyLib1
// ^^ Local dependencies must expose library products in their Package.swift, 
// and the library name must be the same with the target name.
// Otherwise, `swift-sh` won't find the module.

justAFunction() // This is from `MyLib1`

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
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", command]
    process.standardOutput = pipe
    try process.run()
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
