//
//  View+PreviewMocks.swift
//  Clerk
//
//  Created on 2025-01-27.
//

#if os(iOS) || os(macOS)

import ClerkKit
import SwiftUI

extension View {
  /// Injects mock environment values for previews.
  ///
  /// This modifier injects mock versions of all Clerk environment observables:
  /// - `Clerk.mock` for `@EnvironmentObject var clerk: Clerk`
  /// - `AuthState()` for `@EnvironmentObject var authState: AuthState`
  /// - `AuthNavigation()` for `@EnvironmentObject var navigation: AuthNavigation`
  /// - `CodeLimiter()` for `@EnvironmentObject var codeLimiter: CodeLimiter`
  /// - `UserProfileSheetNavigation()` for `@EnvironmentObject var navigation: UserProfileSheetNavigation`
  ///
  /// Note: `ClerkTheme` has a default value and doesn't need to be injected.
  ///
  /// **Important:** This modifier only works when running in SwiftUI previews. When used outside of previews,
  /// it returns the view unchanged without applying any mock configuration.
  ///
  /// Usage:
  /// ```swift
  /// #Preview {
  ///     MyView()
  ///         .clerkPreview()
  /// }
  /// ```
  @MainActor
  package func clerkPreview(isSignedIn: Bool = true) -> some View {
    if EnvironmentDetection.isRunningInPreviews {
      // Configure Clerk.shared so views that access it directly don't fail
      let clerk = Clerk.preview { builder in
        builder.isSignedIn = isSignedIn
      }

      return AnyView(
        environmentObject(clerk)
          .environmentObject(CodeLimiter())
          .environmentObject(UserProfileSheetNavigation())
          .environmentObject(AuthState())
          .environmentObject(AuthNavigation())
      )
    }
    return AnyView(self)
  }
}

#endif
