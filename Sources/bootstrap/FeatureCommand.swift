//
//  FeatureCommand.swift
//  
//
//  Created by Jeremy Greenwood on 3/24/22.
//

import ArgumentParser
import Foundation
import LeafKit
import NIO
import NIOFoundationCompat
import PathKit

enum FeatureOptions: EnumerableFlag {
    case sysenv
    case combined

    static func name(for value: FeatureOptions) -> NameSpecification {
        .shortAndLong
    }

    static func help(for value: FeatureOptions) -> ArgumentHelp? {
        switch value {
        case .sysenv: return "Use SystemEnvironment for the Reducer's Environment generic."
        case .combined: return "Set up a combined reducer."
        }
    }
}

final class FeatureCommand {
    let name: String
    let options: [FeatureOptions]

    init(name: String, options: [FeatureOptions]) {
        self.name = name
        self.options = options
    }

    func run() throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let sources = LeafSources()
        let source = CustomSource(root: "\(Bundle.module.bundlePath)/templates/")
        try sources.register(using: source)

        let renderer = LeafRenderer(
            configuration: .init(rootDirectory: ""),
            sources: sources,
            eventLoop: group.next())

        let domain = try bytes(for: "domain", renderer: renderer)
        let view = try bytes(for: "view", renderer: renderer)
        let test = try bytes(for: "test", renderer: renderer)

        let packagePath = Path("\(Path.current)/Packages/Features")
        let featurePath = packagePath + "Sources/\(name)"
        try? featurePath.mkdir()

        let domainPath = featurePath + "\(name)Domain.swift"
        let viewPath = featurePath + "\(name)View.swift"
        let testPath = packagePath + "Tests/FeaturesTests/\(name)Tests.swift"

        try domainPath.write(Data(buffer: domain))
        try viewPath.write(Data(buffer: view))
        try testPath.write(Data(buffer: test))

        print("✅ feature templates generated\n")
        print("\(String.packageSetup(name: name))")
    }

    func bytes(for file: String, renderer: LeafRenderer) throws -> ByteBuffer {
        try renderer.render(
            path: file,
            context: [
                "name": .string(name),
                "date": .double(Date().timeIntervalSince1970),
                "username": .string(NSFullUserName()),
                "sysenv": .bool(options.contains(.sysenv)),
                "combined": .bool(options.contains(.combined))
            ]).wait()
    }
}

struct CustomSource: LeafSource {
    let root: String

    func file(template: String, escape: Bool, on eventLoop: EventLoop) -> EventLoopFuture<ByteBuffer> {
        let path = root + template

        guard let data = FileManager.default.contents(atPath: path) else {
            return eventLoop.makeFailedFuture(LeafError(.noTemplateExists(template)))
        }

        return eventLoop.makeSucceededFuture(ByteBuffer(data: data))
    }
}

private extension String {
    static func packageSetup(name: String) -> String {
        """
        Add the following to Package.swift:
        Product:
        .library(
            name: "\(name)",
            targets: ["\(name)"]),

        Target:
        .target(
            name: "\(name)",
            dependencies: [
                "Common",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        """
    }
}
