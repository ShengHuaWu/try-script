struct Effect<A> {
    let run: (@escaping (A) -> Void) -> Void // TODO: Append `throws` here to stop sending actions
    
    func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in
            self.run { a in
                let b = f(a)
                callback(b)
            }
        }
    }
}

fileprivate func absurd<T>(_ never: Never) -> T {}

extension Effect where A == Never {
    func fireAndForget<T>() -> Effect<T> {
        return map(absurd)
    }
}

typealias Reducer<State, Action> = (inout State, Action) -> [Effect<Action>]

final class Store<State, Action> {
    private let reducer: Reducer<State, Action>
    private var state: State
    
    init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.reducer = reducer
        self.state = initialState
    }
    
    func send(_ action: Action) {
        let effects = reducer(&state, action)
        effects.forEach { effect in
            effect.run(self.send)
        }
    }
}

func combine<State, Action>(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
    return { state, action in
        return reducers.flatMap { $0(&state, action) }
    }
}

func pullback<GlobalState, LocalState, GlobalAction, LocalAction>(
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

func logging<State, Action>(_ reducer: @escaping Reducer<State, Action>) -> Reducer<State, Action> {
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
