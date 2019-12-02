// Functional way
typealias Effect = () -> Void
typealias Task<State> = (inout State) throws -> [Effect]

func combine<State>(_ tasks: Task<State>...) -> Task<State> {
    return { state in
        return try tasks.flatMap { try $0(&state) }
    }
}

func pullback<GlobalState, LocalState>(_ task: @escaping Task<LocalState>, _ kp: WritableKeyPath<GlobalState, LocalState>) -> Task<GlobalState> {
    return { globalState in
        var localState = globalState[keyPath: kp]
        let outputs = try task(&localState)
        globalState[keyPath: kp] = localState
        return outputs
    }
}
