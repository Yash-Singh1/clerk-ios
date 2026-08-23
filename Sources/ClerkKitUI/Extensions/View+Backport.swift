//
//  View+Backport.swift
//  Clerk
//

#if os(iOS) || os(macOS)

import SwiftUI

enum ClerkSensoryFeedbackStyle {
  case error
  case selection
}

extension View {
  @ViewBuilder
  func clerkAnimatedOpacity<Value: Equatable>(
    _ opacity: Double,
    animation: Animation,
    value: Value
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      self.animation(animation) {
        $0.opacity(opacity)
      }
    } else {
      self
        .opacity(opacity)
        .animation(animation, value: value)
    }
  }

  @ViewBuilder
  func clerkPresentationBackground<S: ShapeStyle>(_ style: S) -> some View {
    #if os(iOS)
    if #available(iOS 16.4, *) {
      presentationBackground(style)
    } else {
      background(style)
    }
    #else
    presentationBackground(style)
    #endif
  }

  @ViewBuilder
  func clerkErrorShake(trigger: Bool) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      phaseAnimator(
        [0, 10, -10, 10, -5, 5, 0],
        trigger: trigger,
        content: { content, offset in
          content.offset(x: offset)
        },
        animation: { _ in
          .linear(duration: 0.06)
        }
      )
    } else {
      self
    }
  }

  @ViewBuilder
  func clerkLastUsedBadgeOffset() -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      visualEffect { content, proxy in
        content.offset(y: -proxy.size.height / 2)
      }
    } else {
      offset(y: -12)
    }
  }

  @ViewBuilder
  func clerkSymbolReplaceTransition() -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      contentTransition(.symbolEffect(.replace))
    } else {
      self
    }
  }

  @ViewBuilder
  func clerkSymbolReplaceOffUpTransition() -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      contentTransition(.symbolEffect(.replace.offUp))
    } else {
      self
    }
  }

  @ViewBuilder
  func clerkPasskeyBounce(value: Bool) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      symbolEffect(.bounce.down, options: .nonRepeating, value: value)
    } else {
      self
    }
  }

  @ViewBuilder
  func clerkBlurReplaceTransition(_ animation: Animation? = nil) -> some View {
    #if os(iOS)
    if #available(iOS 17.0, *) {
      if let animation {
        transition(.blurReplace.animation(animation))
      } else {
        transition(.blurReplace)
      }
    } else if let animation {
      transition(.opacity.animation(animation))
    } else {
      transition(.opacity)
    }
    #else
    if let animation {
      transition(.opacity.animation(animation))
    } else {
      transition(.opacity)
    }
    #endif
  }

  @ViewBuilder
  func clerkSensoryFeedback<Value: Equatable>(
    _ feedback: ClerkSensoryFeedbackStyle,
    trigger: Value
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      switch feedback {
      case .error:
        sensoryFeedback(.error, trigger: trigger)
      case .selection:
        sensoryFeedback(.selection, trigger: trigger)
      }
    } else {
      self
    }
  }

  @ViewBuilder
  func clerkSensoryFeedback<Value: Equatable>(
    _ feedback: ClerkSensoryFeedbackStyle,
    trigger: Value,
    condition: @escaping (Value, Value) -> Bool
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      switch feedback {
      case .error:
        sensoryFeedback(.error, trigger: trigger, condition: condition)
      case .selection:
        sensoryFeedback(.selection, trigger: trigger, condition: condition)
      }
    } else {
      self
    }
  }

  @ViewBuilder
  func clerkOnChange<Value: Equatable>(
    of value: Value,
    initial: Bool = false,
    _ action: @escaping (Value, Value) -> Void
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      onChange(of: value, initial: initial, action)
    } else {
      modifier(ClerkOnChangeModifier(value: value, initial: initial, action: action))
    }
  }

  func clerkOnChange<Value: Equatable>(
    of value: Value,
    initial: Bool = false,
    _ action: @escaping () -> Void
  ) -> some View {
    clerkOnChange(of: value, initial: initial) { _, _ in action() }
  }

  @ViewBuilder
  func clerkContainerRelativeFrame(
    _ axes: Axis.Set,
    count: Int? = nil,
    span: Int = 1,
    spacing: CGFloat = 0
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, *) {
      if let count {
        containerRelativeFrame(axes, count: count, span: span, spacing: spacing)
      } else {
        containerRelativeFrame(axes)
      }
    } else {
      frame(
        maxWidth: axes.contains(.horizontal) ? .infinity : nil,
        maxHeight: axes.contains(.vertical) ? .infinity : nil
      )
    }
  }

  @ViewBuilder
  func clerkScrollBounceBasedOnSize() -> some View {
    #if os(iOS)
    if #available(iOS 16.4, *) {
      scrollBounceBehavior(.basedOnSize)
    } else {
      self
    }
    #else
    scrollBounceBehavior(.basedOnSize)
    #endif
  }
}

private struct ClerkOnChangeModifier<Value: Equatable>: ViewModifier {
  let value: Value
  let initial: Bool
  let action: (Value, Value) -> Void

  @State private var previousValue: Value?

  func body(content: Content) -> some View {
    content
      .onAppear {
        guard previousValue == nil else { return }
        previousValue = value
        if initial {
          action(value, value)
        }
      }
      #if os(iOS)
      .onChange(of: value) { newValue in
        let oldValue = previousValue ?? newValue
        previousValue = newValue
        action(oldValue, newValue)
      }
      #else
      .onChange(of: value) { _, newValue in
        let oldValue = previousValue ?? newValue
        previousValue = newValue
        action(oldValue, newValue)
      }
      #endif
  }
}

#endif
