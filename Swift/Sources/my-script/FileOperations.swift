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

let fileReducer: Reducer<FileState, FileAction> = { state, action in
    switch action {
    case .createDir:
        return [
            Current.commandClient()
                .run(command: "mkdir", arguments: ["-p", state.newTempDir], at: state.downloadsDir)
                .fireAndForget()
        ]
        
    case .createFile:
        return [
            Current.commandClient()
                .run(command: "touch", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
                .fireAndForget()
        ]
        
    case .insertTextToNewFile:
        return [
            Current.commandClient()
                .run(command: "echo", arguments: [state.newText, ">>", state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
                .fireAndForget()
        ]
        
    case .showContentOfNewFile:
        return [
            Current.commandClient()
                .run(command: "cat", arguments: [state.newFile], at: "\(state.downloadsDir)/\(state.newTempDir)")
                .fireAndForget()
        ]
        
    case .listFiles:
        return [
            Current.commandClient()
//                .run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
                .run(command: "ls", arguments: ["-al"], at: "\(state.downloadsDir)/\(state.newTempDir)")
                .fireAndForget()
        ]
        
    case .removeAllFiles:
        return [
            Current.commandClient()
                .run(command: "rm", arguments: ["*"], at: "\(state.downloadsDir)/\(state.newTempDir)")
                .fireAndForget()
        ]
        
    case .removeDir:
        return [
            Current.commandClient()
                .run(command: "rmdir", arguments: [state.newTempDir], at: state.downloadsDir)
                .fireAndForget()
        ]
        
    }
}
