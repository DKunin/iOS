import Foundation

public enum HomeAssistantAuthClient {
    public struct Details: Equatable {
        public let clientID: String
        public let redirectURI: String
        public let callbackScheme: String
    }

    public static func details(isDebug: Bool, for baseURL: URL) -> Details {
        if isDebug, !KuniniSessionCookie.protects(baseURL) {
            return Details(
                clientID: "https://home-assistant.io/iOS/dev-auth",
                redirectURI: "homeassistant-dev://auth-callback",
                callbackScheme: "homeassistant-dev"
            )
        } else {
            return Details(
                clientID: "https://home-assistant.io/iOS",
                redirectURI: "homeassistant://auth-callback",
                callbackScheme: "homeassistant"
            )
        }
    }
}
