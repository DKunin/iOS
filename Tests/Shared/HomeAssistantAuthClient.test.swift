import Foundation
@testable import Shared
import XCTest

final class HomeAssistantAuthClientTests: XCTestCase {
    func testDebugKuniniServerUsesStableCompanionClient() throws {
        let details = try HomeAssistantAuthClient.details(
            isDebug: true,
            for: XCTUnwrap(URL(string: "https://home.kunini.ru"))
        )

        XCTAssertEqual(details.clientID, "https://home-assistant.io/iOS")
        XCTAssertEqual(details.redirectURI, "homeassistant://auth-callback")
        XCTAssertEqual(details.callbackScheme, "homeassistant")
    }

    func testDebugUnrelatedServerKeepsDevelopmentClient() throws {
        let details = try HomeAssistantAuthClient.details(
            isDebug: true,
            for: XCTUnwrap(URL(string: "https://homeassistant.example.com"))
        )

        XCTAssertEqual(details.clientID, "https://home-assistant.io/iOS/dev-auth")
        XCTAssertEqual(details.redirectURI, "homeassistant-dev://auth-callback")
        XCTAssertEqual(details.callbackScheme, "homeassistant-dev")
    }

    func testReleaseBuildUsesStableCompanionClient() throws {
        let details = try HomeAssistantAuthClient.details(
            isDebug: false,
            for: XCTUnwrap(URL(string: "https://homeassistant.example.com"))
        )

        XCTAssertEqual(details.clientID, "https://home-assistant.io/iOS")
        XCTAssertEqual(details.redirectURI, "homeassistant://auth-callback")
        XCTAssertEqual(details.callbackScheme, "homeassistant")
    }
}
