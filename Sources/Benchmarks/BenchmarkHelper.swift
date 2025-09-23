import CollectionsBenchmark

extension Benchmark {
    mutating func add<Input>(
        title: String,
        type: Any.Type,
        input: Input.Type,
        regular: @escaping (Input) -> (Benchmark.TaskBody?),
        forward: @escaping (Input) -> (Benchmark.TaskBody?),
        reverse: @escaping (Input) -> (Benchmark.TaskBody?)
    ) {
        self.add(
            title: "\(type).\(title) - regular",
            input: input,
        ) { input in
            regular(input)
        }
        self.add(
            title: "\(type).\(title) - forward",
            input: input,
        ) { input in
            forward(input)
        }
        self.add(
            title: "\(type).\(title) - reverse",
            input: input,
        ) { input in
            reverse(input)
        }
    }
}
