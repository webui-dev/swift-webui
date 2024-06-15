// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var webuiCSettings: [CSetting] = [
	.define("NDEBUG"),
	.define("NO_CACHING"),
	.define("NO_CGI"),
	.define("USE_WEBSOCKET"),
]
var webuiSources = [
	"src/webui.c",
	"src/civetweb/civetweb.c",
]
var webuiLinkerSettings: [LinkerSetting] = [
	.linkedLibrary("Ws2_32", .when(platforms: [.windows])),
	.linkedLibrary("Ole32", .when(platforms: [.windows])),
	.linkedFramework("WebKit", .when(platforms: [.macOS])),
	.linkedFramework("Cocoa", .when(platforms: [.macOS])),
]

if ProcessInfo.processInfo.environment["USE_TLS"] != nil {
	webuiCSettings += [
		.define("WEBUI_USE_TLS"),
		.define("WEBUI_TLS"),
		.define("NO_SSL_DL"),
		.define("OPENSSL_API_1_1"),
	]
	webuiLinkerSettings += [
		.linkedLibrary("ssl"),
		.linkedLibrary("crypto"),
		.linkedLibrary("Bcrypt", .when(platforms: [.windows])),
	]
} else {
	webuiCSettings += [
		.define("NO_SSL"),
	]
}

#if os(macOS)
	webuiSources += ["src/webview/wkwebview.m"]
#endif

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
			sources: webuiSources,
			cSettings: webuiCSettings,
			linkerSettings: webuiLinkerSettings
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
		.executableTarget(
			name: "ServeAFolder",
			dependencies: ["SwiftWebUI"],
			path: "Examples/ServeAFolder",
			resources: [
				.copy("ui"),
			]
		),
	]
)
