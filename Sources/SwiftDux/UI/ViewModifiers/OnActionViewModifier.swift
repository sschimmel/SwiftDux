import Combine
import SwiftUI

@available(*, deprecated, message: "Use middleware instead.")
public struct OnActionViewModifier: ViewModifier {
  @Environment(\.actionDispatcher) private var actionDispatcher
  private var perform: ActionModifier? = nil

  @usableFromInline internal init(perform: ActionModifier? = nil) {
    self.perform = perform
  }

  public func body(content: Content) -> some View {
    var nextActionDispatcher = actionDispatcher

    if let perform = perform {
      nextActionDispatcher = OnActionDispatcher(actionModifier: perform, nextDispatcher: actionDispatcher)
    }

    return content.environment(\.actionDispatcher, nextActionDispatcher)
  }
}

@available(*, deprecated)
extension OnActionViewModifier {

  /// A closure that can return a new action from a previous one. If no action is returned,
  /// the original action is not sent.
  public typealias ActionModifier = (Action) -> Action?

  private struct OnActionDispatcher: ActionDispatcher {
    var actionModifier: ActionModifier
    var nextDispatcher: ActionDispatcher

    func send(_ action: Action) {
      guard let action = actionModifier(action) else { return }
      nextDispatcher.send(action)
    }

    func sendAsCancellable(_ action: Action) -> Cancellable {
      nextDispatcher.sendAsCancellable(action)
    }
  }
}

extension View {

  /// Fires when a child view dispatches an action.
  ///
  /// - Parameter perform: Calls the closure when an action is dispatched. An optional new action can be returned to change the action.
  /// - Returns: The modified view.
  @available(*, deprecated, message: "Use middleware instead.")
  @inlinable public func onAction(perform: @escaping OnActionViewModifier.ActionModifier) -> some View {
    modifier(OnActionViewModifier(perform: perform))
  }
}
