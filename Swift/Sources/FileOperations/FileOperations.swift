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
            Current.runCommand("mkdir", ["-p", state.newTempDir], state.downloadsDir)
        ]
        
    case .createFile:
        return [
            Current.runCommand("touch", [state.newFile], "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .insertTextToNewFile:
        return [
            Current.runCommand("echo", [state.newText, ">>", state.newFile], "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .showContentOfNewFile:
        return [
            Current.runCommand("cat", [state.newFile], "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .listFiles:
        return [
            Current.runCommand("ls", ["-al"], "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .removeAllFiles:
        return [
            Current.runCommand("rm", ["*"], "\(state.downloadsDir)/\(state.newTempDir)")
        ]
        
    case .removeDir:
        return [
            Current.runCommand("rmdir", [state.newTempDir], state.downloadsDir)
        ]
        
    case let .print(output):
        
        return [
            Effect { _ in
                print(output)
            }
        ]
        
    case let .exit(message):
        state.exitMessage = message
        
        return []
    }
}
