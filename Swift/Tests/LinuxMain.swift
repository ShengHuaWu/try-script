import XCTest

import my_scriptTests

var tests = [XCTestCaseEntry]()
tests += my_scriptTests.allTests()
XCTMain(tests)
