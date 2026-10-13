import Foundation
import MenuItems

let version = "0.1.0"

let usage = """
usage: menu-items <command>

commands:
  list [--ignore <glob>]...   print menu bar extras as JSON, ordered right to left
                              globs match identifier, bundle_id, title or app
  press <target>              click a menu bar extra; target is <pid>:<index>,
                              <pid>/<identifier> or a glob (first match)
  trust                       check Accessibility permission and prompt if missing
  help                        show this help
  version                     print the version

examples:
  menu-items list --ignore 'com.apple.menuextra.*'
  menu-items press com.apple.menuextra.clock    # opens Notification Center
"""

func requireTrust() throws {
    guard Accessibility.isTrusted(prompt: false) else { throw MenuItemsError.untrusted }
}

func execute(_ command: Command) throws {
    switch command {
    case .list(let patterns):
        try requireTrust()
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        FileHandle.standardOutput.write(try encoder.encode(MenuExtras.list(ignoring: patterns)))
        print()
    case .press(let target):
        try requireTrust()
        try MenuExtras.press(target)
    case .trust:
        print(Accessibility.isTrusted(prompt: true) ? "trusted" : "not trusted")
    case .help:
        print(usage)
    case .version:
        print(version)
    }
}

func fail(_ message: String, code: Int32) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(code)
}

do {
    try execute(Command(arguments: Array(CommandLine.arguments.dropFirst())))
} catch MenuItemsError.invalidArguments {
    fail(usage, code: 64)
} catch {
    fail("menu-items: \(error)", code: 1)
}
