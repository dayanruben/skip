// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "skip",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
    ],
    products: [
        .plugin(name: "skipstone", targets: ["skipstone"]),
        .plugin(name: "skiplink", targets: ["Create SkipLink"]),
        .library(name: "SkipDrive", targets: ["SkipDrive"]),
        .library(name: "SkipTest", targets: ["SkipTest"]),
    ],
    targets: [
        .plugin(name: "skipstone", capability: .buildTool(), dependencies: ["skip"], path: "Plugins/SkipPlugin"),
        .plugin(name: "Create SkipLink", capability: .command(intent: .custom(verb: "SkipLink", description: "Create local links to transpiled output"), permissions: [.writeToPackageDirectory(reason: "This command will create local links to the skipstone output for the specified package(s), enabling access to the transpiled Kotlin")]), dependencies: ["skip"], path: "Plugins/SkipLink"),
        .target(name: "SkipDrive", dependencies: ["skipstone", .target(name: "skip")]),
        .target(name: "SkipTest", dependencies: [.target(name: "SkipDrive", condition: .when(platforms: [.macOS, .linux]))]),
        .testTarget(name: "SkipTestTests", dependencies: ["SkipTest"]),
        .testTarget(name: "SkipDriveTests", dependencies: ["SkipDrive"]),
    ]
)

let env = Context.environment
if (env["SKIPLOCAL"] != nil || env["PWD"]?.hasSuffix("skipstone") == true) {
    package.dependencies += [.package(path: env["SKIPLOCAL"] ?? "../skipstone")]
    package.targets += [.executableTarget(name: "skip", dependencies: [.product(name: "SkipBuild", package: "skipstone")])]
} else {
    #if os(macOS)
    package.targets += [.binaryTarget(name: "skip", url: "https://source.skip.tools/skip/releases/download/1.8.11/skip-macos.zip", checksum: "f48718991893b5a5f4878541a21ab5b9219e2845234b7ba22f80818028d3d32a")]
    #elseif os(Linux)
    package.targets += [.binaryTarget(name: "skip", url: "https://source.skip.tools/skip/releases/download/1.8.11/skip-linux.zip", checksum: "2bf7cb1b15391d9241707eacc3806e28ec8a5b95a4dda251efbae8f418460dc5")]
    #else
    package.dependencies += [.package(url: "https://source.skip.tools/skipstone.git", exact: "1.8.11")]
    package.targets += [.executableTarget(name: "skip", dependencies: [.product(name: "SkipBuild", package: "skipstone")])]
    #endif
}

