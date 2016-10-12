import PackageDescription

let package = Package(
    name: "StructuredQuery",
	targets: [
		Target(name: "Basic", dependencies: []),
		Target(name: "Types", dependencies: ["Basic"]),
		Target(name: "Schema", dependencies: ["Types"]),
		Target(name: "Expression", dependencies: ["Schema"]),
		Target(name: "Compiler", dependencies: ["Expression"]),
	]

)
