import Foundation
import Shared
import WebKit

enum OnboardingKuniniSessionCookieSync {
    @MainActor
    static func syncIfNeeded(
        for serverURL: URL,
        from cookieStore: WKHTTPCookieStore,
        into destination: HTTPCookieStorage = .shared
    ) async throws {
        guard KuniniSessionCookie.protects(serverURL) else { return }

        let cookies = await withCheckedContinuation { continuation in
            cookieStore.getAllCookies { continuation.resume(returning: $0) }
        }
        try syncIfNeeded(for: serverURL, cookies: cookies, into: destination)
    }

    static func syncIfNeeded(
        for serverURL: URL,
        cookies: [HTTPCookie],
        into destination: HTTPCookieStorage,
        now: Date = Date()
    ) throws {
        guard KuniniSessionCookie.protects(serverURL) else { return }
        guard let cookie = cookies.first(where: { KuniniSessionCookie.isUsable($0, now: now) }),
              KuniniSessionCookie.replace(with: cookie, in: destination, now: now) else {
            throw URLError(.userAuthenticationRequired)
        }
    }
}
