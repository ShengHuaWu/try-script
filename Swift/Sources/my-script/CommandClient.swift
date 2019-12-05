import Foundation

final class CommandClient {
    @discardableResult
    func run(command: String, arguments: [String] = [], at path: String = ".") -> Effect<FileAction> {
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
                    print("Run \(command) fails: \(error.localizedDescription)")
                    callback(.exit)
                }
            }
        } else {
            process.launch()
        }
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if !errorData.isEmpty, let errorMessage = String(data: errorData, encoding: .utf8) {
            return Effect { callback in
                print("Run \(command) error occurs: \(errorMessage)")
                callback(.exit)
            }
        }
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? "There is no output for \(command)"
        
        return Effect { _ in
            if !output.isEmpty {
                print(output)
            }
        }
    }
}
