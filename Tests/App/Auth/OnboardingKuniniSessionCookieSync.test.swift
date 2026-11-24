import Foundation
@testable import HomeAssistant
import Shared
import XCTest

final class OnboardingKuniniSessionCookieSyncTests: XCTestCase {
    private var storage: HTTPCookieStorage!

    override func setUp() {
        super.setUp()
        storage = .sharedCookieStorage(forGroupContainerIdentifier: "KuniniAuthTests.\(UUID().uuidString)")
    }

    override func tearDown() {
        storage = nil
        super.tearDown()
    }

    func testProtectedServerCopiesSharedSecureSession() throws {
        let cookie = try makeCookie(domain: ".kunini.ru", secure: true)

        try OnboardingKuniniSessionCookieSync.syncIfNeeded(
            for: XCTUnwrap(URL(string: "https://home.kunini.ru/auth/authorize")),
            cookies: [cookie],
            into: storage
        )

        XCTAssertEqual(storage.cookies?.map(\.name), [KuniniSessionCookie.name])
    }

    func testProtectedServerRejectsHostOnlyAuthCookie() throws {
        let cookie = try makeCookie(domain: "auth.kunini.ru", secure: true)

        XCTAssertThrowsError(try OnboardingKuniniSessionCookieSync.syncIfNeeded(
            for: XCTUnwrap(URL(string: "https://home.kunini.ru/auth/authorize")),
            cookies: [cookie],
            into: storage
        )) { error in
            XCTAssertEqual((error as? URLError)?.code, .userAuthenticationRequired)
        }
    }

    func testProtectedServerRejectsInsecureSessionCookie() throws {
        let cookie = try makeCookie(domain: ".kunini.ru", secure: false)

        XCTAssertThrowsError(try OnboardingKuniniSessionCookieSync.syncIfNeeded(
            for: XCTUnwrap(URL(string: "https://home.kunini.ru/auth/authorize")),
            cookies: [cookie],
            into: storage
        ))
    }

    func testProtectedServerRejectsExpiredSessionCookie() throws {
        let cookie = try makeCookie(domain: ".kunini.ru", secure: true, expires: Date().addingTimeInterval(-1))

        XCTAssertThrowsError(try OnboardingKuniniSessionCookieSync.syncIfNeeded(
            for: XCTUnwrap(URL(string: "https://home.kunini.ru/auth/authorize")),
            cookies: [cookie],
            into: storage
        ))
    }

    func testUnrelatedServerDoesNotRequireKuniniSession() throws {
        try OnboardingKuniniSessionCookieSync.syncIfNeeded(
            for: XCTUnwrap(URL(string: "https://homeassistant.example.com/auth/authorize")),
            cookies: [],
            into: storage
        )

        XCTAssertTrue(storage.cookies?.isEmpty ?? true)
    }

    private func makeCookie(
        domain: String,
        secure: Bool,
        expires: Date = Date().addingTimeInterval(300)
    ) throws -> HTTPCookie {
        var properties: [HTTPCookiePropertyKey: Any] = [
            .domain: domain,
            .path: "/",
            .name: KuniniSessionCookie.name,
            .value: "test-session-token",
            .expires: expires,
        ]
        if secure {
            properties[.secure] = "TRUE"
        }
        return try XCTUnwrap(HTTPCookie(properties: properties))
    }
}
