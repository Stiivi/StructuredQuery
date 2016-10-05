import PackageDescription

let package = Package(
    name: "StructuredQuery",
	targets: [
		Target(name: "Expression", dependencies: []),
		Target(name: "Compiler", dependencies: ["Expression"]),
	]

)
