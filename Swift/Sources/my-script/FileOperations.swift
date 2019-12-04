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

// TODO: Move `run` to environment
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

// TODO: Handle throwing logic
let fileReducer: Reducer<FileState, FileAction> = { state, action in
    switch action {
    case .createDir:
        do {
            try run(command: "mkdir", arguments: ["-p", state.newTempDir], at: state.downloadsDir)
            return []
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    case .createFile:
        do {
            try run(command: "touch", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
            return []
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    case .insertTextToNewFile:
        do {
            try run(command: "echo", arguments: [state.newText, ">>", state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
            return []
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    case .showContentOfNewFile:
        do {
            let output = try run(command: "cat", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
            return [
                Effect { _ in print(output) }
            ]
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    case .listFiles:
        do {
            let output = try run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
            return [
                Effect { _ in print(output) }
            ]
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    case .removeAllFiles:
        do {
            try run(command: "rm", arguments: ["*"], at: "\(state.downloadsDir)/\(state.newTempDir)")
            return []
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    case .removeDir:
        do {
            try run(command: "rmdir", arguments: [state.newTempDir], at: state.downloadsDir)
            return []
        } catch {
            return [
                Effect { _ in
                    print("Error occurs: \n\(error.localizedDescription)")
                }
            ]
        }
        
    }
}
