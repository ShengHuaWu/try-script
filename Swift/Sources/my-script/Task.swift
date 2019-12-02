// Functional way
typealias Task<State> = (inout State) throws -> Void

func combine<State>(_ tasks: Task<State>...) -> Task<State> {
    return { state in
        try tasks.forEach { try $0(&state) }
    }
}

func pullback<GlobalState, LocalState>(_ task: @escaping Task<LocalState>, _ kp: WritableKeyPath<GlobalState, LocalState>) -> Task<GlobalState> {
    return { globalState in
        var localState = globalState[keyPath: kp]
        try task(&localState)
        globalState[keyPath: kp] = localState
    }
}
