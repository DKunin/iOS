@testable import HomeAssistant
import SwiftUI
import Testing
import UIKit

struct OnboardingAuthLoginViewTests {
    @MainActor @Test func kuniniServerStartsWithQueryFreeSessionPreflight() throws {
        let baseURL = try #require(URL(string: "https://home.kunini.ru"))
        let viewModel = try OnboardingAuthLoginViewModel(authDetails: OnboardingAuthDetails(baseURL: baseURL))

        #expect(viewModel.requestURLForTests == baseURL)
        #expect(viewModel.requestURLForTests.query == nil)
    }

    @MainActor @Test func unrelatedServerStartsWithHomeAssistantAuthorization() throws {
        let baseURL = try #require(URL(string: "https://homeassistant.example.com"))
        let viewModel = try OnboardingAuthLoginViewModel(authDetails: OnboardingAuthDetails(baseURL: baseURL))

        #expect(viewModel.requestURLForTests.path == "/auth/authorize")
        #expect(viewModel.requestURLForTests.queryItems?["response_type"] == "code")
    }

    /// The web view is laid out edge to edge, so a horizontal safe area inset (iPhone Duo camera
    /// or vertical bar) must not narrow it; WebKit insets the page content itself.
    @MainActor @Test func webViewSpansTheWholeWidthPastTheSafeArea() throws {
        let baseURL = try #require(URL(string: "http://homeassistant.local:8123"))
        let viewModel = try OnboardingAuthLoginViewModel(authDetails: OnboardingAuthDetails(baseURL: baseURL))
        let controller = UIHostingController(rootView: OnboardingAuthLoginView(viewModel: viewModel))
        controller.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 80)
        // The representable only reaches the hierarchy inside a window. The window never becomes
        // key: the snapshot helpers draw into whatever window is key, so taking it would reach into
        // unrelated tests.
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 390, height: 844)))
        window.rootViewController = controller
        window.isHidden = false

        window.layoutIfNeeded()

        let webViewWidth = viewModel.webView.frame.width
        #expect(webViewWidth == 390, "web view width \(webViewWidth) should fill the window, ignoring the 80pt inset")
        window.isHidden = true
        window.rootViewController = nil
    }
}
