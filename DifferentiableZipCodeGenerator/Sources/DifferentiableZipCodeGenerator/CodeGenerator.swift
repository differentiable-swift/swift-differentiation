import Foundation

@main
struct CodeGenerator {
    static func main() throws {
        guard CommandLine.arguments.count == 3 else {
            throw CodeGeneratorError.invalidArguments
        }
        // arguments[0] is the path to this command line tool
        let output = URL(filePath: CommandLine.arguments[1])

        guard let upToArity = Int(CommandLine.arguments[2]) else {
            throw CodeGeneratorError.invalidArguments
        }

        for arity in 2 ... upToArity {
            let zipDifferentiableFileURL = output.appending(component: "Zip+DifferentiableArity\(arity).swift")

            let code = ZipSequenceGenerator.generateFor(arity: arity)
            try code.write(to: zipDifferentiableFileURL, atomically: true, encoding: .utf8)
        }
    }
}

enum CodeGeneratorError: Error {
    case invalidArguments
    case invalidData
}
