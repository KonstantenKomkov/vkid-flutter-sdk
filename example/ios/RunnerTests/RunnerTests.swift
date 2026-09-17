import Flutter
import UIKit
import XCTest


@testable import vkid_flutter_sdk

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

    func testLogs() {
        let plugin = VkidFlutterSdkPlugin()
        let call = FlutterMethodCall(methodName: "areLogsEnabled", arguments: [])
        let resultExpectation = expectation(description: "result block must be called.")
        plugin.handle(call) { result in
          XCTAssertTrue(result is Bool)
          resultExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
