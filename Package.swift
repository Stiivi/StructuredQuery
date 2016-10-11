import PackageDescription

let package = Package(
    name: "StructuredQuery",
	targets: [
		Target(name: "Common", dependencies: []),
		Target(name: "Types", dependencies: ["Common"]),
		Target(name: "Schema", dependencies: ["Types"]),
		Target(name: "Expression", dependencies: ["Schema"]),
		Target(name: "Compiler", dependencies: ["Expression"]),
	]

)
