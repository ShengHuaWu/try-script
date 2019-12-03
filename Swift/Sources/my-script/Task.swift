// TODO: Store implementation
typealias Effect<Action> = (@escaping (Action) -> Void) -> Void

// TODO: Handle throwing
typealias Reducer<State, Action> = (inout State, Action) throws -> [Effect<Action>]

func combine<State, Action>(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
    return { state, action in
        return try reducers.flatMap { try $0(&state, action) }
    }
}

// TODO: View implementation

// TODO: Global action to local action
func pullback<GlobalState, LocalState, Action>(_ task: @escaping Reducer<LocalState, Action>, _ kp: WritableKeyPath<GlobalState, LocalState>) -> Reducer<GlobalState, Action> {
    return { globalState, action in
        var localState = globalState[keyPath: kp]
        let outputs = try task(&localState, action)
        globalState[keyPath: kp] = localState
        return outputs
    }
}

func logging<State, Action>(_ task: @escaping Reducer<State, Action>) -> Reducer<State, Action> {
    return { state, action in
        let effects = try task(&state, action)
        let newState = state
        return [
            { _ in
                print("Action: \(action)")
                print("State:")
                dump(newState)
                print("===============")
            }
        ] + effects
    }
}
