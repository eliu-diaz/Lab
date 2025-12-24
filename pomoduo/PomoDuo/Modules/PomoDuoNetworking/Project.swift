import ProjectDescription

let featureName = "PomoDuoNetworking"

let project = Project(
    name: featureName,
    targets: [
        .target(
            name: featureName,
            destinations: [.mac],
            product: .framework,
            bundleId: "dev.eliudiaz.\(featureName)",
            dependencies: [
                .external(name: "Factory")
            ]
        ),
        .target(
            name: "\(featureName)Tests",
            destinations: [.mac],
            product: .unitTests,
            bundleId: "dev.eliudiaz.\(featureName)Tests",
            sources: "Tests/**",
            dependencies: [
                .target(name: featureName)
            ]
        )
    ]
)
