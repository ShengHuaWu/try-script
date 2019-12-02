// Functional way
typealias Effect<A> = () -> A
typealias Task<State, Output> = (inout State) throws -> [Effect<Output>]

func combine<State, Output>(_ tasks: Task<State, Output>...) -> Task<State, Output> {
    return { state in
        return try tasks.flatMap { try $0(&state) }
    }
}

func map<State, A, B>(_ task: @escaping Task<State, A>, _ f: @escaping (A) -> B) -> Task<State, B> {
    return { state in
        return try task(&state).map { effect in
            let a = effect()
            return {
                f(a)
            }
        }
    }
}

func pullback<GlobalState, LocalState, Output>(_ task: @escaping Task<LocalState, Output>, _ kp: WritableKeyPath<GlobalState, LocalState>) -> Task<GlobalState, Output> {
    return { globalState in
        var localState = globalState[keyPath: kp]
        let outputs = try task(&localState)
        globalState[keyPath: kp] = localState
        return outputs
    }
}
