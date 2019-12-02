import Foundation

struct FileState {
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
    var outputs: [String]
}

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
