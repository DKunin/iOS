import Foundation
@testable import Shared
import XCTest

final class KuniniSessionCookieTests: XCTestCase {
    func testProtectedURLRequiresHTTPSKuniniSubdomain() throws {
        XCTAssertTrue(try KuniniSessionCookie.protects(XCTUnwrap(URL(string: "https://home.kunini.ru"))))
        XCTAssertFalse(try KuniniSessionCookie.protects(XCTUnwrap(URL(string: "http://home.kunini.ru"))))
        XCTAssertFalse(try KuniniSessionCookie.protects(XCTUnwrap(URL(string: "https://home.kunini.ru.evil.test"))))
        XCTAssertFalse(try KuniniSessionCookie.protects(XCTUnwrap(URL(string: "https://evilkunini.ru"))))
    }

    func testProtectedURLUsesSharedCookieStorageForEphemeralSession() throws {
        let storage = HTTPCookieStorage.sharedCookieStorage(
            forGroupContainerIdentifier: "KuniniSessionTests.\(UUID().uuidString)"
        )
        let configuration = URLSessionConfiguration.ephemeral

        try KuniniSessionCookie.configure(
            configuration,
            for: [XCTUnwrap(URL(string: "https://home.kunini.ru"))],
            cookieStorage: storage
        )

        XCTAssertTrue(configuration.httpCookieStorage === storage)
        XCTAssertTrue(configuration.httpShouldSetCookies)
        XCTAssertEqual(configuration.httpCookieAcceptPolicy, .always)
    }

    func testUnrelatedURLKeepsSessionConfigurationUnchanged() throws {
        let configuration = URLSessionConfiguration.ephemeral
        let originalStorage = configuration.httpCookieStorage
        let originalShouldSetCookies = configuration.httpShouldSetCookies
        let originalAcceptPolicy = configuration.httpCookieAcceptPolicy

        try KuniniSessionCookie.configure(
            configuration,
            for: [XCTUnwrap(URL(string: "https://homeassistant.example.com"))]
        )

        XCTAssertTrue(configuration.httpCookieStorage === originalStorage)
        XCTAssertEqual(configuration.httpShouldSetCookies, originalShouldSetCookies)
        XCTAssertEqual(configuration.httpCookieAcceptPolicy, originalAcceptPolicy)
    }
}
