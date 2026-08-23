//
//  AuthNavigation+PostAuth.swift
//  Clerk
//

#if os(iOS) || os(macOS)

import ClerkKit

extension AuthNavigation {
  var presentedAuthFlowToken: AuthFlowPresentationToken? {
    path.reversed().compactMap(\.authFlowPresentationToken).first
  }

  func routeToTrustedDeviceEnrollment(
    token: AuthFlowPresentationToken,
    biometryDisplayName: TrustedDeviceBiometryDisplayName
  ) {
    guard token.kind == .trustedDeviceEnrollment else { return }
    if presentedAuthFlowToken == token {
      return
    }

    synchronizePostAuthPath(with: token)
    path.append(.trustedDeviceEnrollment(
      biometryDisplayName: biometryDisplayName,
      token: token
    ))
  }

  func synchronizePostAuthPath(with token: AuthFlowPresentationToken?) {
    guard let presentedToken = presentedAuthFlowToken else { return }
    guard presentedToken != token else { return }
    if let token, presentedToken.work == token.work {
      return
    }
    clearPostAuthPath()
  }

  func synchronizePostAuthPath(with work: AuthFlowWork) {
    guard let presentedToken = presentedAuthFlowToken,
          presentedToken.work != work
    else {
      return
    }
    clearPostAuthPath()
  }

  func resetForNewAuthFlow() {
    path = []
  }

  var hasTrustedDeviceEnrollmentInPath: Bool {
    path.contains { destination in
      if case .trustedDeviceEnrollment = destination {
        true
      } else {
        false
      }
    }
  }

  func clearPostAuthPath() {
    guard let firstPostAuthIndex = path.firstIndex(where: {
      $0.authFlowPresentationToken != nil
    }) else {
      return
    }
    path.removeSubrange(firstPostAuthIndex...)
  }
}

#endif
