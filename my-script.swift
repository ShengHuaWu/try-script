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

func tryScript() throws {
//    let help1 = try shellOut(to: "sh", arguments: ["adb-run-tests.sh", "-h"], at: "~/Development/swift-everywhere-toolchain/Platypus")
//    print(help1)
//    
//    let help2 = try shellOut(to: "make", arguments: ["help"], at: "~/Development/swift-everywhere-toolchain")
//    print(help2)
    
    let downloadsDir = "~/Downloads"
    let newTempDir = "NewTemp"
    let newFile = "my-file.txt"
    let newFile1 = "my-file1.txt"
    let newFile2 = "my-file2.txt"
    let newText = "this is a good text."
    
    let mkdir = try shellOut(to: "mkdir", arguments: ["-p", newTempDir], at: downloadsDir)
    print(mkdir)
    
    let touch = try shellOut(to: "touch", arguments: [newFile], at: "\(downloadsDir)/\(newTempDir)")
    print(touch)
    
    let echo = try shellOut(to: "echo", arguments: [newText, ">>", newFile], at: "\(downloadsDir)/\(newTempDir)")
    print(echo)
    
    let cat1 = try shellOut(to: "cat", arguments: [newFile], at: "\(downloadsDir)/\(newTempDir)")
    print(cat1)
    
    let ls1 = try shellOut(to: "ls", arguments: ["-al"], at: "\(downloadsDir)/\(newTempDir)")
    print(ls1)
    
    let cp = try shellOut(to: "cp", arguments: [newFile, newFile1], at: "\(downloadsDir)/\(newTempDir)")
    print(cp)
    
    let ls2 = try shellOut(to: "ls", arguments: ["-al"], at: "\(downloadsDir)/\(newTempDir)")
    print(ls2)
    
    let cat2 = try shellOut(to: "cat", arguments: [newFile1], at: "\(downloadsDir)/\(newTempDir)")
    print(cat2)
    
    let mv = try shellOut(to: "mv", arguments: [newFile, newFile2], at: "\(downloadsDir)/\(newTempDir)")
    print(mv)
    
    let ls3 = try shellOut(to: "ls", arguments: ["-al"], at: "\(downloadsDir)/\(newTempDir)")
    print(ls3)
    
    let cat3 = try shellOut(to: "cat", arguments: [newFile2], at: "\(downloadsDir)/\(newTempDir)")
    print(cat3)
    
    let rm = try shellOut(to: "rm", arguments: ["*"], at: "\(downloadsDir)/\(newTempDir)")
    print(rm)
    
    let rmdir = try shellOut(to: "rmdir", arguments: [newTempDir], at: downloadsDir)
    print(rmdir)
    
    let ls4 = try shellOut(to: "ls", arguments: ["-al"], at: downloadsDir)
    print(ls4)
}

do {
    try tryScript()
} catch let error {
    print("Error occurs: \n\(error.localizedDescription)")
}
