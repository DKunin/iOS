import Foundation
import Shared

class OnboardingAuthDetails: Equatable {
    var url: URL
    var scheme: String
    var exceptions: SecurityExceptions = .init()
    var clientCertificate: ClientCertificate?

    init(baseURL: URL) throws {
        guard var components = URLComponents(url: baseURL.serverBaseURL(), resolvingAgainstBaseURL: false) else {
            throw OnboardingAuthError(kind: .invalidURL)
        }

        let client = HomeAssistantAuthClient.details(
            isDebug: Current.appConfiguration == .debug,
            for: baseURL
        )

        components.path = "/auth/authorize"
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: client.clientID),
            URLQueryItem(name: "redirect_uri", value: client.redirectURI),
        ]

        guard let authURL = components.url else {
            throw OnboardingAuthError(kind: .invalidURL)
        }

        self.url = authURL
        self.scheme = client.callbackScheme
    }

    static func == (lhs: OnboardingAuthDetails, rhs: OnboardingAuthDetails) -> Bool {
        lhs.url == rhs.url &&
            lhs.scheme == rhs.scheme &&
            lhs.exceptions == rhs.exceptions &&
            lhs.clientCertificate == rhs.clientCertificate
    }
}
