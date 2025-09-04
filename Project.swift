import ProjectDescription

let project = Project(
    name: "ToDoList",
    targets: [
        .target(
            name: "ToDoList",
            destinations: .iOS,
            product: .app,
            bundleId: "bbb.com.To-Do-List",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .file(path: "Sources/Info.plist"),
            sources: [
                "Sources/**",
                "Features/**",
                "Shared/**"
            ],
            resources: [
                "Resources/Assets.xcassets",
                "Resources/To_Do_List.xcdatamodeld",
                "Resources/**"
            ],
            dependencies: [
                .external(name: "SnapKit")
            ]
        )
    ]
)
