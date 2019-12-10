import Foundation
import Composable

public struct FileState {
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
    public var exitMessage: String?
    
    public init(exitMessage: String?) {
        self.exitMessage = exitMessage
    }
}

public enum FileAction {
    case createDir
    case createFile
    case insertTextToNewFile
    case showContentOfNewFile
    case listFiles
    case removeAllFiles
    case removeDir
    case print(String)
    case exit(String)
}

public let fileReducer: Reducer<FileState, FileAction> = { state, action in
    switch action {
    case .createDir:
        return [
            Current.run(CommandInput(command: "mkdir", arguments: ["-p", state.newTempDir], path: state.downloadsDir))
        ]
        
    case .createFile:
        return [
            Current.run(CommandInput(command: "touch", arguments: [state.newFile], path: "\(state.downloadsDir)/\(state.newTempDir)"))
        ]
        
    case .insertTextToNewFile:
        return [
            Current.run(CommandInput(command: "echo", arguments: [state.newText, ">>", state.newFile], path: "\(state.downloadsDir)/\(state.newTempDir)"))
        ]
        
    case .showContentOfNewFile:
        return [
            Current.run(CommandInput(command: "cat", arguments: [state.newFile], path: "\(state.downloadsDir)/\(state.newTempDir)"))
        ]
        
    case .listFiles:
        return [
            Current.run(CommandInput(command: "ls", arguments: ["-al"], path: "\(state.downloadsDir)/\(state.newTempDir)"))
        ]
        
    case .removeAllFiles:
        return [
            Current.run(CommandInput(command: "rm", arguments: ["*"], path: "\(state.downloadsDir)/\(state.newTempDir)"))
        ]
        
    case .removeDir:
        return [
            Current.run(CommandInput(command: "rmdir", arguments: [state.newTempDir], path: state.downloadsDir))
        ]
        
    case let .print(output):
        return [
            Current.print(output).fireAndForget()
        ]
        
    case let .exit(message):
        state.exitMessage = message
        
        return []
    }
}
