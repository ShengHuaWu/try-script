import Foundation
import TSCUtility // External dependency
// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/

final class ArgumentParsingClient {
    private let parser = ArgumentParser(commandName: "my-script", usage: "argument parsing & more ...", overview: "This is a testing script ✌️")
    private var enableOption: OptionArgument<Bool>
    private var inputOption: OptionArgument<String>
    
    init() {
        enableOption = parser.add(option: "--enable",
                                  shortName: "-e",
                                  kind: Bool.self,
                                  usage: "✌️ Enable something",
                                  completion: ShellCompletion.none)
        
        inputOption = parser.add(option: "--input",
                                 shortName: "-i",
                                 kind: String.self,
                                 usage: "An input filename",
                                 completion: .filename)
    }
    
    func parse() -> Effect<Never> {
        let argsv = Array(CommandLine.arguments.dropFirst())
        do {
            let parguments = try parser.parse(argsv)
            var enableOutput = ""
            if let isEnabled = parguments.get(enableOption) {
                enableOutput = "Enabled: \(isEnabled)"
            }
            
            var inputOutput = ""
            if let filename = parguments.get(inputOption) {
                inputOutput = "Using filename: \(filename)"
            }
            
            return Effect { _ in
                print(enableOutput)
                print(inputOutput)
            }
            
        // TODO: Merge throwing logic, e.g. convenient method of `Effect`
        } catch ArgumentParserError.expectedValue(let value) {
            return Effect { _ in
                print("Missing value for argument \(value).")
            }
        } catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
            return Effect { _ in
                print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
            }
        } catch {
            return Effect { _ in
                print("Error occurs: \n\(error.localizedDescription)")
            }
        }
    }
}
