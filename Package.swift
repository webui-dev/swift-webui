// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftWebUI",
	products: [
		.library(
			name: "SwiftWebUI",
			targets: ["SwiftWebUI"]
		),
	],
	targets: [
		.target(
			name: "SwiftWebUI",
			dependencies: ["webui"]
		),
		.target(
			name: "webui",
			dependencies: [],
			exclude: [
				"examples",
				"bridge",
				"CMakeLists.txt",
			],
			sources: [
				"src/webui.c",
				"src/civetweb/civetweb.c",
			],
			cSettings: [
				.define("NDEBUG"),
				.define("NO_CACHING"),
				.define("NO_CGI"),
				.define("USE_WEBSOCKET"),
				.define("NO_SSL"),
			]
		),
		// Examples
		.executableTarget(
			name: "Minimal",
			dependencies: ["SwiftWebUI"],
			path: "Examples/Minimal"
		),
		.executableTarget(
			name: "CallSwiftFromJS",
			dependencies: ["SwiftWebUI"],
			path: "Examples/CallSwiftFromJS"
		),
	]
)
