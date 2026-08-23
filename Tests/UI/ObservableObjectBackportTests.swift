#if os(iOS) || os(macOS)

@testable import ClerkKit
@testable import ClerkKitUI
import Combine
import SwiftUI
import Testing

@MainActor
@Suite
struct ObservableObjectBackportTests {
  @Test
  func authStatePublishesBindingAndConfigurationChanges() {
    let state = AuthState()
    var changeCount = 0
    let observation = state.objectWillChange.sink {
      changeCount += 1
    }

    state.authStartIdentifier = "person@example.com"
    state.configure(AuthConfig(initialFirstName: "Taylor"))

    #expect(changeCount >= 2)
    withExtendedLifetime(observation) {}
  }

  @Test
  func navigationAndCodeLimiterPublishChanges() {
    let navigation = AuthNavigation()
    let codeLimiter = CodeLimiter()
    var navigationDidChange = false
    var limiterChangeCount = 0
    let navigationObservation = navigation.objectWillChange.sink {
      navigationDidChange = true
    }
    let limiterObservation = codeLimiter.objectWillChange.sink {
      limiterChangeCount += 1
    }

    navigation.path.append(.authStart)
    codeLimiter.recordCodeSent(for: "person@example.com")
    codeLimiter.clearRecord(for: "person@example.com")

    #expect(navigationDidChange)
    #expect(limiterChangeCount >= 2)
    withExtendedLifetime((navigationObservation, limiterObservation)) {}
  }

  @Test
  func themePublishesInPlaceMutation() {
    let theme = ClerkTheme()
    var didChange = false
    let observation = theme.objectWillChange.sink {
      didChange = true
    }

    theme.design = .init(borderRadius: 24)

    #expect(didChange)
    withExtendedLifetime(observation) {}
  }

}

#endif
