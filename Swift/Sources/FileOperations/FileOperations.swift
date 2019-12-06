import Foundation
import Composable

public struct FileState {
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
    public var shouldExit: Bool
    
    public init(shouldExit: Bool) {
        self.shouldExit = shouldExit
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
    case exit
}

public let fileReducer: Reducer<FileState, FileAction> = { state, action in
    switch action {
    case .createDir:
        return [
            Current.commandClient()
                .run(command: "mkdir", arguments: ["-p", state.newTempDir], at: state.downloadsDir)
        ]
        
    case .createFile:
        return [
            Current.commandClient()
                .run(command: "touch", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .insertTextToNewFile:
        return [
            Current.commandClient()
                .run(command: "echo", arguments: [state.newText, ">>", state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .showContentOfNewFile:
        return [
            Current.commandClient()
                .run(command: "cat", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .listFiles:
        return [
            Current.commandClient()
                .run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .removeAllFiles:
        return [
            Current.commandClient()
                .run(command: "rm", arguments: ["*"], at: "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .removeDir:
        return [
            Current.commandClient()
                .run(command: "rmdir", arguments: [state.newTempDir], at: state.downloadsDir)
        ]
        
    case .exit:
        state.shouldExit = true
        
        return []
    }
}
