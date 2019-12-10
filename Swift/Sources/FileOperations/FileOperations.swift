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
            Current.run(CommandInput(command: "mkdir", arguments: ["-p", state.newTempDir], path: state.downloadsDir)).handleCommandResult()
        ]
        
    case .createFile:
        return [
            Current.run(CommandInput(command: "touch", arguments: [state.newFile], path: "\(state.downloadsDir)/\(state.newTempDir)")).handleCommandResult()
        ]
        
    case .insertTextToNewFile:
        return [
            Current.run(CommandInput(command: "echo", arguments: [state.newText, ">>", state.newFile], path: "\(state.downloadsDir)/\(state.newTempDir)")).handleCommandResult()
        ]
        
    case .showContentOfNewFile:
        return [
            Current.run(CommandInput(command: "cat", arguments: [state.newFile], path: "\(state.downloadsDir)/\(state.newTempDir)")).handleCommandResult()
        ]
        
    case .listFiles:
        return [
            Current.run(CommandInput(command: "ls", arguments: ["-al"], path: "\(state.downloadsDir)/\(state.newTempDir)")).handleCommandResult()
        ]
        
    case .removeAllFiles:
        return [
            Current.run(CommandInput(command: "rm", arguments: ["*"], path: "\(state.downloadsDir)/\(state.newTempDir)")).handleCommandResult()
        ]
        
    case .removeDir:
        return [
            Current.run(CommandInput(command: "rmdir", arguments: [state.newTempDir], path: state.downloadsDir)).handleCommandResult()
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

extension Effect where A == Result<String, EffectError> {
    func handleCommandResult() -> Effect<FileAction> {
        return map { result in
            switch result {
            case let .success(output):
                return .print(output)
            case let .failure(error):
                return .exit(error.message)
            }
        }
    }
}
