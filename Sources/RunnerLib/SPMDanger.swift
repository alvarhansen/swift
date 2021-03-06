import Foundation

public struct SPMDanger {
    private static let dangerDepsPrefix = "DangerDeps"
    public static let buildFolder = ".build/debug"
    public let depsLibName: String

    public init?(packagePath: String = "Package.swift") {
        let packageContent = (try? String(contentsOfFile: packagePath)) ?? ""

        let regex = try? NSRegularExpression(pattern: "\\.library\\(name:[\\ ]?\"(\(SPMDanger.dangerDepsPrefix)[A-Za-z]*)",
                                             options: .allowCommentsAndWhitespace)
        let firstMatch = regex?.firstMatch(in: packageContent,
                                           options: .withTransparentBounds,
                                           range: NSRange(location: 0, length: packageContent.count))

        if let depsLibNameRange = firstMatch?.range(at: 1),
            let range = Range(depsLibNameRange, in: packageContent) {
            depsLibName = String(packageContent[range])
        } else {
            return nil
        }
    }

    public func buildDepsIfNeeded(executor: ShellOutExecuting = ShellOutExecutor(),
                                  fileManager: FileManager = .default) {
        if !fileManager.fileExists(atPath: "\(SPMDanger.buildFolder)/lib\(depsLibName).dylib"), // OSX
            !fileManager.fileExists(atPath: "\(SPMDanger.buildFolder)/lib\(depsLibName).so") { // Linux
            _ = try? executor.shellOut(command: "swift build --product \(depsLibName)")
        }
    }

    public var libImport: String {
        return "-l\(depsLibName)"
    }
}
