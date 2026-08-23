//
//  SignInFactorTwoBackupCodeView.swift
//  Clerk
//

#if os(iOS) || os(macOS)

import ClerkKit
import SwiftUI

struct SignInFactorTwoBackupCodeView: View {
  @EnvironmentObject private var clerk: Clerk
  @Environment(\.clerkTheme) private var theme
  @EnvironmentObject private var navigation: AuthNavigation
  @EnvironmentObject private var authState: AuthState

  @FocusState private var isFocused: Bool
  @State private var fieldError: Error?

  var signIn: SignIn? {
    clerk.auth.currentSignIn
  }

  let factor: Factor

  var body: some View {
    @ObservedObject var authState = authState

    ScrollView {
      VStack(spacing: 0) {
        VStack(spacing: 8) {
          HeaderView(style: .title, text: "Enter a backup code")
          HeaderView(style: .subtitle, text: "Your backup code is the one you got when setting up two-step verification.")
        }
        .padding(.bottom, 32)

        VStack(spacing: 24) {
          VStack(spacing: 8) {
            ClerkTextField(
              "Backup code",
              text: $authState.signInBackupCode,
              fieldState: fieldError != nil ? .error : .default
            )
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
            .focused($isFocused)
            .onFirstAppear {
              isFocused = true
            }

            if let fieldError {
              ErrorText(error: fieldError, alignment: .leading)
                .font(theme.fonts.subheadline)
                .clerkBlurReplaceTransition(.default.speed(2))
                .id(fieldError.localizedDescription)
            }
          }

          AsyncButton {
            await submit()
          } label: { isRunning in
            ContinueButtonLabelView(isActive: isRunning)
          }
          .buttonStyle(.primary())
          .disabled(authState.signInBackupCode.isEmpty)
          .simultaneousGesture(TapGesture())
        }
        .padding(.bottom, 16)

        Button {
          navigation.path.append(
            AuthView.Destination.signInFactorTwoUseAnotherMethod(
              currentFactor: factor
            )
          )
        } label: {
          Text("Use another method", bundle: .module)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(
          .primary(
            config: .init(
              emphasis: .none,
              size: .small
            )
          )
        )
        .padding(.bottom, 32)

        SecuredByClerkView()
      }
      .padding(16)
    }
    .background(theme.colors.background)
    .clerkSensoryFeedback(.error, trigger: fieldError?.localizedDescription) {
      $1 != nil
    }
  }
}

extension SignInFactorTwoBackupCodeView {
  func submit() async {
    isFocused = false

    do {
      guard var signIn else {
        navigation.path = []
        return
      }

      signIn = try await signIn.verifyMfaCode(authState.signInBackupCode, type: .backupCode)

      fieldError = nil
      navigation.setToStepForStatus(signIn: signIn)
    } catch {
      fieldError = error
    }
  }
}

#Preview {
  SignInFactorTwoBackupCodeView(factor: .mockBackupCode)
    .environment(\.clerkTheme, .clerk)
}

#endif
