import Foundation
import Composable

struct CommandInput {
    let command: String
    let arguments: [String]
    let path: String
}

func bash(with input: CommandInput) -> Effect<Result<String, EffectError>> {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    let command = "cd \(input.path.replacingOccurrences(of: " ", with: "\\ ")) && \(input.command) \(input.arguments.joined(separator: " "))"
    if #available(OSX 10.13, *) {
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
    } else {
        process.launchPath = "bin/bash"
    }
    process.arguments = ["-c", command]
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    if #available(OSX 10.13, *) {
        do {
            try process.run()
        } catch {
            return Effect { callback in
                callback(.failure("Run command \(input.command) with arguments \(input.arguments) at path \(input.path) fails: \n\(error.localizedDescription)."))
            }
        }
    } else {
        process.launch()
    }
    process.waitUntilExit()
    
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    if !errorData.isEmpty, let errorMessage = String(data: errorData, encoding: .utf8) {
        return Effect { callback in
            callback(.failure("Run command \(input.command) with arguments \(input.arguments) at path \(input.path) fails: \n\(errorMessage)."))
        }
    }
    
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? "There is no output for \(command)"
    
    return Effect { callback in
        callback(.success(output))
    }
}
