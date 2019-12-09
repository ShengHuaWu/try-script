import Foundation
import Composable

struct CommandError: Error {
    let message: String
}

// TODO: Do we still need this?
struct CommandClient {
    func run(command: String, arguments: [String] = [], at path: String) -> Effect<Result<String, CommandError>> {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let command = "cd \(path.replacingOccurrences(of: " ", with: "\\ ")) && \(command) \(arguments.joined(separator: " "))"
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
                    callback(.failure(.init(message: "Run \(command) fails: \(error.localizedDescription)")))
                }
            }
        } else {
            process.launch()
        }
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if !errorData.isEmpty, let errorMessage = String(data: errorData, encoding: .utf8) {
            return Effect { callback in
                callback(.failure(.init(message: "Run \(command) error occurs: \(errorMessage)")))
            }
        }
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? "There is no output for \(command)"
        
        return Effect { callback in
            callback(.success(output))
        }
    }
}
