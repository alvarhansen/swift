---
title: Extending Danger
subtitle: Plugin creation
layout: guide_sw
order: 1
blurb: How to take your rules, and make them accessible to more people by writing a Danger plugin.
---

You've built a few rules now, and you think you've wrote something that's useful in a more general sense. So, rather
than copy & paste between all your Dangerfiles, it's time to move that code into a plugin.

A plugin in this context is nothing too special, it's a Swift Package Manager library that you create which exposes some
functions to your Dangerfile. With luck, you should be able to basically copy and paste your rules - add a test or two
and then you're good to go.

You can get started by making a new SwiftPM package, chance are you've never done this, so lets run through it here:

Start by making a new folder, then making a new package:

```sh
mkdir DangerNoCopyrights/
cd DangerNoCopyrights/
swift package init --type library

  Creating library package: DangerNoCopyrights
  Creating Package.swift
  Creating README.md
  Creating .gitignore
  Creating Sources/
  Creating Sources/DangerNoCopyrights/DangerNoCopyrights.swift
  Creating Tests/
  Creating Tests/LinuxMain.swift
  Creating Tests/DangerNoCopyrightsTests/
  Creating Tests/DangerNoCopyrightsTests/DangerNoCopyrightsTests.swift
  Creating Tests/DangerNoCopyrightsTests/XCTestManifests.swift
```

You will need to add Danger as a dependency, if you want to work with Xcode, first run
`swift package generate-xcodeproj` to create an Xcode Project, then edit your `Package.swift`:

```diff
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
-       // .package(url: /* package url */, from: "1.0.0"),
+       .package(url: "https://github.com/danger/danger-swift.git", from: "0.7.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DangerNoCopyrights",
-           dependencies: []),
+           dependencies: ["Danger"]),
        .testTarget(
            name: "DangerNoCopyrightsTests",
            dependencies: ["DangerNoCopyrights"]),
    ]
)
```

Make those changes and run `swift package update` to have Swift PM add Danger to your dependencies. For writing
something simple, you can expose a single function in your library:

```swift
import Danger
import Foundation

public func checkForCopyrightHeaders() -> Void {
    let danger = Danger()

    let swiftFilesWithCopyright = danger.git.createdFiles.filter {
        $0.fileType == .swift
            && danger.utils.readFile($0).contains("//  Created by")
    }

    if swiftFilesWithCopyright.count > 0 {
        let files = swiftFilesWithCopyright.joined(separator: ", ")
        warn("Please don't include copyright headers, found them in: \(files)")
    }
}
```

### Writing your Plugin

Danger Swift doesn't have a good way to use a plugin locally yet, so you'll need to make a release of your module to try
it in your local.

Do that by committing your changes, and making a git tag.

```sh
git init
git add .
git remote add origin [your repo]
git tag 0.0.1
git push --tags
```

### Adding it to your Dangerfile

You need to provide two bits of information in your Dangerfile, the name of your library and where it can be found:

```diff
import Danger
import Foundation
// Reference your library, then note to Danger where it can be found
+ import DangerNoCopyrights // package: https://[your repo].git

+ checkForCopyrightHeaders()
```

Danger will download and set up your plugin before running your `Dangerfile.swift`.

### Part Two

This is enough to get started, if you want to move it up a level check out
[Extending Danger Two](extending_danger_two.html).
