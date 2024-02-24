import Foundation
import AppKit

extension NSRunningApplication {
    var name: String? {
        guard let url = self.bundleURL else { return nil }
        return url.deletingPathExtension().lastPathComponent
    }
}

func getFrontmostApplication() -> NSRunningApplication? {
    return NSWorkspace.shared.frontmostApplication
}

func getNextApplication(startingWith letter: Character) -> NSRunningApplication? {
    let runningApps = NSWorkspace.shared.runningApplications
        .filter { $0.activationPolicy == .regular }
        .filter { $0.name?.first?.lowercased() == letter.lowercased() }
        .sorted { ($0.name ?? "") < ($1.name ?? "") }
    
    if let frontmostApp = getFrontmostApplication(),
       let index = runningApps.firstIndex(of: frontmostApp),
       index < runningApps.count - 1 {
        return runningApps[index + 1]
    } else if let nextApp = runningApps.first {
        return nextApp
    }
    return nil
}

let args = CommandLine.arguments
guard args.count > 1, let searchLetter = args[1].first else {
    print("Please provide a valid search letter as a command-line argument.")
    exit(1)
}

if let nextApp = getNextApplication(startingWith: searchLetter),
   nextApp != getFrontmostApplication(),
   let appURL = nextApp.bundleURL {
    NSWorkspace.shared.open(appURL)
}
