public struct Effect<A> {
    fileprivate let run: (@escaping (A) -> Void) -> Void
    
    public init(_ run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }
    
    func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in
            self.run { a in
                let b = f(a)
                callback(b)
            }
        }
    }
}

extension Effect where A == Never {
    private func absurd<T>(_ never: Never) -> T {}
    
    public func fireAndForget<T>() -> Effect<T> {
        return map(absurd)
    }
}

public typealias Reducer<State, Action> = (inout State, Action) -> [Effect<Action>]

public final class Store<State, Action> {
    private let reducer: Reducer<State, Action>
    private var state: State
    
    public init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.reducer = reducer
        self.state = initialState
    }
    
    public func send(_ action: Action) {
        let effects = reducer(&state, action)
        effects.forEach { effect in
            effect.run(self.send)
        }
    }
}

public func combine<State, Action>(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
    return { state, action in
        return reducers.flatMap { $0(&state, action) }
    }
}

public func pullback<GlobalState, LocalState, GlobalAction, LocalAction>(
    _ reducer: @escaping Reducer<LocalState, LocalAction>,
    value: WritableKeyPath<GlobalState, LocalState>,
    action: WritableKeyPath<GlobalAction, LocalAction?>) -> Reducer<GlobalState, GlobalAction> {
    return { globalState, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        
        let localEffects = reducer(&globalState[keyPath: value], localAction)
        
        return localEffects.map { localEffect in
            Effect { callback in
                localEffect.run { localAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    callback(globalAction)
                }
            }
        }
    }
}

public func logging<State, Action>(_ reducer: @escaping Reducer<State, Action>) -> Reducer<State, Action> {
    return { state, action in
        let effects = reducer(&state, action)
        let newState = state
        return [
            Effect { _ in
                print("Action: \(action)")
                print("State:")
                dump(newState)
                print("===============")
            }
        ] + effects
    }
}
