import Foundation

struct FileState {
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
}

@discardableResult
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
    let output = try run(command: "sh adb-run-tests.sh", arguments: ["-h"], at: "~/Development/swift-everywhere-toolchain/Platypus")
    return [
        { print(output) }
    ]
}

let makeHelp: Task<FileState> = { state in
    let output = try run(command: "make", arguments: ["help"], at: "~/Development/swift-everywhere-toolchain")
    return [
        { print(output) }
    ]
}

let createDir: Task<FileState> = { state in
    try run(command: "mkdir", arguments: ["-p", state.newTempDir], at: state.downloadsDir)
    return []
}

let createFile: Task<FileState> = { state in
    try run(command: "touch", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
    return []
}

let insertTextToNewFile: Task<FileState> = { state in
    try run(command: "echo", arguments: [state.newText, ">>", state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
    return []
}

let showContentOfNewFile: Task<FileState> = { state in
    let output = try run(command: "cat", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
    return [
        { print(output) }
    ]
}

let listFiles: Task<FileState> = { state in
    let output = try run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
    return [
        { print(output) }
    ]
}

let removeAllFiles: Task<FileState> = { state in
    try run(command: "rm", arguments: ["*"], at: "\(state.downloadsDir)/\(state.newTempDir)")
    return []
}

let removeDir: Task<FileState> = { state in
    try run(command: "rmdir", arguments: [state.newTempDir], at: state.downloadsDir)
    return []
}

let file: Task<FileState> = combine(
    customHelp,
    makeHelp,
    createDir,
    createFile,
    insertTextToNewFile,
    showContentOfNewFile,
    listFiles,
    removeAllFiles,
    removeDir
)
