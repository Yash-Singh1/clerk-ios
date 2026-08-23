//
//  OrganizationProfileNavigation.swift
//

#if os(iOS) || os(macOS)

import Combine
import Foundation
import SwiftUI

/// Navigation API for navigating from custom rows to custom destinations inside
/// `OrganizationProfileView`.
@MainActor
public final class OrganizationProfileNavigator<Route: Hashable>: ObservableObject {
  private let pushRow: @MainActor (Route) -> Void
  private let popToRootAction: @MainActor () -> Void

  init(
    push: @escaping @MainActor (Route) -> Void,
    popToRoot: @escaping @MainActor () -> Void
  ) {
    pushRow = push
    popToRootAction = popToRoot
  }

  public func push(_ route: Route) {
    pushRow(route)
  }

  /// Pops any pushed custom destinations and returns to the root screen of
  /// `OrganizationProfileView`.
  public func popToRoot() {
    popToRootAction()
  }
}

enum OrganizationProfileBuiltInDestination: Hashable {
  case members
  case verifiedDomains
}

enum OrganizationProfileDismissAction {
  case popToRoot
  case exitOrganizationProfile
}

/// Internal built-in-only adapter for Clerk-owned child views that should not know about
/// the host app's custom `Route` type but still need to trigger profile navigation.
@MainActor
final class OrganizationProfileBuiltInRouter: ObservableObject {
  private let pushDestination: @MainActor (OrganizationProfileBuiltInDestination) -> Void
  private let dismissAction: @MainActor (OrganizationProfileDismissAction) -> Void

  init(
    push: @escaping @MainActor (OrganizationProfileBuiltInDestination) -> Void,
    dismissAction: @escaping @MainActor (OrganizationProfileDismissAction) -> Void
  ) {
    pushDestination = push
    self.dismissAction = dismissAction
  }

  func push(_ destination: OrganizationProfileBuiltInDestination) {
    pushDestination(destination)
  }

  func dismiss(_ action: OrganizationProfileDismissAction) {
    dismissAction(action)
  }
}

#endif
