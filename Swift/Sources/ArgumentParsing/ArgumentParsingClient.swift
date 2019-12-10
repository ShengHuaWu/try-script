import Foundation
import Composable
import TSCUtility // External dependency
// Arguments (options) parsing
// For more parsing rules, please read https://rderik.com/blog/command-line-argument-parsing-using-swift-package-manager-s/

struct ArgumentParsingClient {
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
    
    func parse() -> Effect<Result<ParsingResult, EffectError>> {
        let argsv = Array(CommandLine.arguments.dropFirst())
        do {
            let parguments = try parser.parse(argsv)
            let result: ParsingResult = (
                isEnabled: parguments.get(enableOption) ?? false,
                inputDir: parguments.get(inputOption)
            )
            
            return Effect { callback in
                callback(.success(result))
            }
        } catch ArgumentParserError.expectedValue(let value) {
            return Effect { callback in
                callback(.failure("Missing value for argument \(value)."))
            }
        } catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
            return Effect { callback in
                callback(.failure("Parser: \(parser) Missing arguments: \(stringArray.joined())."))
            }
        } catch {
            return Effect { callback in
                callback(.failure("Error occurs: \n\(error.localizedDescription)."))
            }
        }
    }
}
