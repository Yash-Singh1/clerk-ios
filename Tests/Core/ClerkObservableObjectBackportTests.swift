@testable import ClerkKit
import Combine
import Testing

@MainActor
@Suite
struct ClerkObservableObjectBackportTests {
  @Test
  func authFlowCoordinatorMutationPublishesWithoutAClientMutation() throws {
    let clerk = Clerk.mockSignedOut
    var didChange = false
    let observation = clerk.objectWillChange.sink {
      didChange = true
    }

    let registration = try #require(clerk.registerAuthFlow())

    #expect(didChange)
    withExtendedLifetime(observation) {}
    withExtendedLifetime(registration) {}
  }

  @Test
  func sessionCacheMutationPublishes() {
    let clerk = Clerk.mock
    var didChange = false
    let observation = clerk.objectWillChange.sink {
      didChange = true
    }

    clerk.sessionsByUserId = [:]

    #expect(didChange)
    withExtendedLifetime(observation) {}
  }

  @Test
  func callbackContinuationMutationPublishes() {
    let clerk = Clerk.mock
    var didChange = false
    let observation = clerk.objectWillChange.sink {
      didChange = true
    }

    clerk.setCallbackContinuation(nil)

    #expect(didChange)
    withExtendedLifetime(observation) {}
  }

  @Test
  func environmentRefreshPublishesTheCheckpointChange() async throws {
    let clerk = Clerk.mock
    clerk.dependencies = MockDependencyContainer(
      apiClient: createMockAPIClient(runtimeScope: clerk.runtimeScope)
    )
    var changeCount = 0
    let observation = clerk.objectWillChange.sink {
      changeCount += 1
    }

    _ = try await clerk.refreshEnvironment()

    // One publication is for the environment value and one is for the refresh
    // checkpoint consumed by ClerkKitUI.
    #expect(changeCount >= 2)
    withExtendedLifetime(observation) {}
  }
}
