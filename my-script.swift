#!/usr/bin/swift sh

import Foundation

// External dependencies
import ShellOut // @JohnSundell ~> 2.2.0

// Local dependencies
import MyLib1 // ./MyLib1
// ^^ Local dependencies must expose library products in their Package.swift, 
// and the library name must be the same with the target name.
// Otherwise, `swift-sh` won't find the module.

justAFunction() // This is from `MyLib1`

struct State {
    var path: String
    var fileExtension: String
    
    static let initial = State(path: "~/Development/Swift/try-script", fileExtension: "swift")
}

//typealias Task = (inout State) -> Void

// 1. Go to some directory
// 2. List all files and sub-directory with a specific extension

func main() {
    let initialState = State.initial

    do {
        let shellOutOutput = try shellOut(to: "ls", arguments: ["-al", initialState.path + "/*.\(initialState.fileExtension)"])
        print(shellOutOutput)
    } catch let error {
        print("error is \n\(error.localizedDescription)")
    }
}

main()
