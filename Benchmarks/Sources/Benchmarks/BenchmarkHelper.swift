import CollectionsBenchmark

extension Benchmark {
    mutating func addImplementation<Input, C>(
        title: String,
        type: C.Type = C.self,
        input: Input.Type = Input.self,
        regular: @escaping (Input) -> (Benchmark.TaskBody?),
        forward: @escaping (Input) -> (Benchmark.TaskBody?),
        reverse: @escaping (Input) -> (Benchmark.TaskBody?)
    ) {
        self.add(
            title: "\(type).\(title) - regular",
            input: input
        ) { input in
            regular(input)
        }
        self.add(
            title: "\(type).\(title) - forward",
            input: input
        ) { input in
            forward(input)
        }
        self.add(
            title: "\(type).\(title) - reverse",
            input: input
        ) { input in
            reverse(input)
        }
    }

    mutating func add<Input>(
        title: String,
        type: Input.Type = Input.self,
        regular: @escaping (Input) -> (Benchmark.TaskBody?),
        forward: @escaping (Input) -> (Benchmark.TaskBody?),
        reverse: @escaping (Input) -> (Benchmark.TaskBody?)
    ) {
        self.addImplementation(
            title: title,
            type: type,
            input: type,
            regular: regular,
            forward: forward,
            reverse: reverse
        )
    }

    mutating func add<Input>(
        title: String,
        type: Input.Type = Input.self,
        regular: @escaping (Input, Input) -> (Benchmark.TaskBody?),
        forward: @escaping (Input, Input) -> (Benchmark.TaskBody?),
        reverse: @escaping (Input, Input) -> (Benchmark.TaskBody?)
    ) {
        self.addImplementation(
            title: title,
            type: type,
            input: (Input, Input).self,
            regular: regular,
            forward: forward,
            reverse: reverse
        )
    }
}
