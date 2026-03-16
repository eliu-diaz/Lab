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
                .external(name: "FactoryKit"),
                .project(target: "PomoDuoSession", path: .path("Modules/PomoDuoSession"), status: .optional),
                .project(target: "PomoDuoTimer", path: .path("Modules/PomoDuoTimer"), status: .optional),
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
