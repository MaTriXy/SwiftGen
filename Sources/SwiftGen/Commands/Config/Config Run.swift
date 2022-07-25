//
// SwiftGen
// Copyright © 2020 SwiftGen
// MIT Licence
//

import ArgumentParser
import SwiftGenCLI

extension Commands.Config {
  struct Run: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Run commands listed in the configuration file.")

    @OptionGroup
    var config: ConfigOptions

    @Flag
    var logLevel: CommandLogLevel = .default

    func validate() throws {
      try config.validateExists()
    }

    func run() throws {
      do {
        commandLogLevel = logLevel

        let configuration = try config.load()

        logMessage(.info, "Executing configuration file \(config.file)")
        try config.file.parent().chdir {
          try configuration.runCommands(logLevel: commandLogLevel)
        }
      } catch let error as Config.Error {
        logMessage(.error, error)
        logMessage(.error, """
        It seems like there was an error running SwiftGen.

        - Verify that your configuration file exists at the correct path, or create a new one using:
        > swiftgen config init

        - Verify that your configuration file is valid by running:
        > swiftgen config lint

        - If you have any other questions or issues, we have extensive documentation and an issue tracker on GitHub:
        > https://github.com/SwiftGen/SwiftGen
        """)
      }
    }
  }
}
