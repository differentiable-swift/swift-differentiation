import Foundation

@main
struct CodeGenerator {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            throw CodeGeneratorError.invalidArguments
        }
        // arguments[0] is the path to this command line tool
        let output = URL(filePath: CommandLine.arguments[1])

        let zipDifferentiableFileURL = output.appending(component: "Zip+Differentiable.swift")

        let zipDifferenctiableCode = ZipSequenceGenerator.generate(upToArity: 10)

        try zipDifferenctiableCode.write(to: zipDifferentiableFileURL, atomically: true, encoding: .utf8)
    }
}

enum CodeGeneratorError: Error {
    case invalidArguments
    case invalidData
}
