import ProjectDescription

let project = Project(
    name: "Tasks",
    targets: [
        .target(
            name: "Tasks",
            destinations: .iOS,
            product: .app,
            bundleId: "bbb.com.Tasks",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .file(path: "Sources/Info.plist"),
            sources: [
                "Sources/**",
                "Features/**",
                "Shared/**"
            ],
            resources: [
                "Resources/Assets.xcassets",
                "Resources/Base.lproj/**",
                "Resources/Tasks.xcdatamodeld"
            ],
            dependencies: [
                .external(name: "SnapKit")
            ]
        )
    ]
)
