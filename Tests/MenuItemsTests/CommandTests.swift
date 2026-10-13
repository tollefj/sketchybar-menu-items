import MenuItems
import Testing

struct CommandTests {
    @Test func parsesList() throws {
        #expect(try Command(arguments: ["list"]) == .list(ignore: []))
    }

    @Test func parsesRepeatedIgnore() throws {
        let command = try Command(arguments: ["list", "--ignore", "a", "--ignore", "b*"])
        #expect(command == .list(ignore: ["a", "b*"]))
    }

    @Test func parsesPress() throws {
        #expect(try Command(arguments: ["press", "123:0"]) == .press("123:0"))
    }

    @Test(arguments: [["help"], ["-h"], ["--help"]])
    func parsesHelp(arguments: [String]) throws {
        #expect(try Command(arguments: arguments) == .help)
    }

    @Test(arguments: [["version"], ["--version"]])
    func parsesVersion(arguments: [String]) throws {
        #expect(try Command(arguments: arguments) == .version)
    }

    @Test(arguments: [
        [], ["bogus"], ["press"], ["press", "a", "b"], ["trust", "x"],
        ["list", "--ignore"], ["list", "--bogus", "x"]
    ])
    func rejectsInvalid(arguments: [String]) {
        #expect(throws: MenuItemsError.invalidArguments) { try Command(arguments: arguments) }
    }
}
