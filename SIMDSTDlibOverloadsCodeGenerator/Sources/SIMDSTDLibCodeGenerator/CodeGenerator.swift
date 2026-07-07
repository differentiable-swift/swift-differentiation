import Foundation

@main
struct CodeGenerator {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            print("expected usage: CodeGenerator <output-directory>")
            throw CodeGeneratorError.invalidArguments
        }
        // arguments[0] is the path to this command line tool
        let output = URL(filePath: CommandLine.arguments[1])

        let simdWidths = [2, 3, 4, 8, 16, 32, 64]
        let floatingPointTypes = ["Float", "Double"]

        for simdWidth in simdWidths {
            for floatingPointType in floatingPointTypes {
                let simdOverloadsFileURL = output.appending(component: "SIMD\(simdWidth)+\(floatingPointType)STDLibOverloads.swift")
                let simdOverloadsCode = STDLibOverloadsGenerator.generateFor(floatingPointType: floatingPointType, simdWidth: simdWidth)
                try simdOverloadsCode.write(to: simdOverloadsFileURL, atomically: true, encoding: .utf8)
            }
        }
    }
}

enum CodeGeneratorError: Error {
    case invalidArguments
}
