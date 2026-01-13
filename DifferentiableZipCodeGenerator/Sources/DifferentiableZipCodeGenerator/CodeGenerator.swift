import Foundation

@main
struct CodeGenerator {
    static func main() throws {
        guard CommandLine.arguments.count == 3 else {
            print("expected usage: CodeGenerator <output-directory> <arity>")
            throw CodeGeneratorError.invalidArguments
        }
        // arguments[0] is the path to this command line tool
        let output = URL(filePath: CommandLine.arguments[1])

        guard let upToArity = Int(CommandLine.arguments[2]) else {
            print("expected usage: CodeGenerator <output-directory> <arity>")
            throw CodeGeneratorError.invalidArguments
        }

        for arity in 2 ... upToArity {
            let zipSequenceFileURL = output.appending(component: "ZipSequence+Arity\(arity).swift")
            let zipSequenceCode = ZipSequenceGenerator.generateFor(arity: arity)
            try zipSequenceCode.write(to: zipSequenceFileURL, atomically: true, encoding: .utf8)

            let zipWithFileURL = output.appending(component: "ZipWith+Arity\(arity).swift")
            let zipWithCode = ZipWithGenerator.generateFor(arity: arity)
            try zipWithCode.write(to: zipWithFileURL, atomically: true, encoding: .utf8)

            let zipWithInoutFileURL = output.appending(component: "ZipWithInout+Arity\(arity).swift")
            let zipWithInoutCode = ZipWithInoutGenerator.generateFor(arity: arity)
            try zipWithInoutCode.write(to: zipWithInoutFileURL, atomically: true, encoding: .utf8)
        }
    }
}

enum CodeGeneratorError: Error {
    case invalidArguments
}

func indent(_ indent: Int) -> String {
    (0 ..< indent).map { _ in "    " }.joined()
}
