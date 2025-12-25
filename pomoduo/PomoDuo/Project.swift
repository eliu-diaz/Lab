import ProjectDescription

let project = Project(
    name: "PomoDuo",
    targets: [
        .target(
            name: "PomoDuo",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.eliudiaz.PomoDuo",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "PomoDuo/Sources",
                "PomoDuo/Resources",
            ],
            dependencies: [
                .external(name: "FactoryKit")
            ]
        ),
        .target(
            name: "PomoDuoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.eliudiaz.PomoDuoTests",
            infoPlist: .default,
            buildableFolders: [
                "PomoDuo/Tests"
            ],
            dependencies: [
                .target(name: "PomoDuo")
            ]
        ),
    ]
)
