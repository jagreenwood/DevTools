//
//  main.swift
//  
//
//  Created by Jeremy Greenwood on 3/24/22.
//

import ArgumentParser
import Foundation
import PathKit

enum Command: String, ExpressibleByArgument {
    case feature
}

struct Bootstrap: ParsableCommand {
    @Argument(help: "The command to issue")
    var command: Command

    @Argument(help: ArgumentHelp("The name of the feature", valueName: "feature-name"))
    var featureName: String?

    @Flag
    var featureOptions: [FeatureOptions] = []

    mutating func run() throws {
        switch command {
        case .feature:
            guard let name = featureName else { throw "feature command requires feature name" }

            let featureCommand = FeatureCommand(name: name, options: featureOptions)
            try featureCommand.run()
        }
    }
}

Bootstrap.main()
