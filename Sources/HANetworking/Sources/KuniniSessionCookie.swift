import Foundation

public enum KuniniSessionCookie {
    public static let name = "__Secure-kunini_session"

    private static let domain = "kunini.ru"

    public static func protects(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https", let host = url.host?.lowercased() else { return false }
        return host == domain || host.hasSuffix(".\(domain)")
    }

    public static func isUsable(_ cookie: HTTPCookie, now: Date = Date()) -> Bool {
        let isUnexpired = cookie.expiresDate.map { $0 > now } ?? true

        return hasExpectedScope(cookie) && cookie.isSecure && isUnexpired
    }

    @discardableResult
    public static func replace(
        with cookie: HTTPCookie,
        in storage: HTTPCookieStorage = .shared,
        now: Date = Date()
    ) -> Bool {
        guard isUsable(cookie, now: now) else { return false }

        (storage.cookies ?? [])
            .filter(hasExpectedScope)
            .forEach(storage.deleteCookie)
        storage.setCookie(cookie)
        return true
    }

    public static func configure(
        _ configuration: URLSessionConfiguration,
        for urls: [URL],
        cookieStorage: HTTPCookieStorage = .shared
    ) {
        guard urls.contains(where: protects) else { return }

        configuration.httpCookieStorage = cookieStorage
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
    }

    private static func hasExpectedScope(_ cookie: HTTPCookie) -> Bool {
        let cookieDomain = cookie.domain
            .lowercased()
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return cookie.name == name && cookieDomain == domain && cookie.path == "/"
    }
}
