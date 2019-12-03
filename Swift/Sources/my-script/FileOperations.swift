import Foundation

struct FileState {
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
}

enum FileAction {
    case createDir
    case createFile
    case insertTextToNewFile
    case showContentOfNewFile
    case listFiles
    case removeAllFiles
    case removeDir
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

let fileReducer: Reducer<FileState, FileAction> = { state, action in
    switch action {
    case .createDir:
        try run(command: "mkdir", arguments: ["-p", state.newTempDir], at: state.downloadsDir)
        return []
        
    case .createFile:
        try run(command: "touch", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
        return []
        
    case .insertTextToNewFile:
        try run(command: "echo", arguments: [state.newText, ">>", state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
        return []
        
    case .showContentOfNewFile:
        let output = try run(command: "cat", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
        return [
            { _ in print(output) }
        ]
        
    case .listFiles:
        let output = try run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
        return [
            { _ in print(output) }
        ]
        
    case .removeAllFiles:
        try run(command: "rm", arguments: ["*"], at: "\(state.downloadsDir)/\(state.newTempDir)")
        return []
        
    case .removeDir:
        try run(command: "rmdir", arguments: [state.newTempDir], at: state.downloadsDir)
        return []
    }
}
