
import PackagePlugin

@main
struct CodeGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target _: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let output = context.pluginWorkDirectoryURL

        let outputFile = output.appending(component: "Zip+Differentiable.swift")

        return [
            .buildCommand(
                displayName: "Generate Code",
                executable: try context.tool(named: "CodeGeneratorExecutable").url,
                arguments: [output.relativePath],
                environment: [:],
                inputFiles: [],
                outputFiles: [outputFile]
            ),
        ]
    }
}
