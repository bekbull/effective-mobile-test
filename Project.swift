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
            sources: ["Sources/**"],
            resources: [
                "Resources/Assets.xcassets",
                "Resources/Base.lproj/**",
                "Resources/To_Do_List.xcdatamodeld"
            ],
            dependencies: []
        )
    ]
)
