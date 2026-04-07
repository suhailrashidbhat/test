// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BubblePop",
    platforms: [
        .iOS(.v16)
    ],
    targets: [
        .executableTarget(
            name: "BubblePop",
            path: "Sources/BubblePop",
            resources: [],
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "BubblePop",
                "CFBundleIdentifier": "com.bubblepop.game",
                "CFBundleVersion": "1",
                "CFBundleShortVersionString": "1.0",
                "LSRequiresIPhoneOS": true,
                "UIRequiresFullScreen": true,
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait"
                ],
                "UILaunchScreen": [:]
            ])
        )
    ]
)
