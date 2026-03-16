import ProjectDescription

let featureName = "PomoDuoSession"

let project = Project(
    name: featureName,
    targets: [
        .target(
            name: featureName,
            destinations: [.mac, .iPhone],
            product: .framework,
            bundleId: "dev.eliudiaz.\(featureName)",
            sources: "Sources/**",
            dependencies: [
                .external(name: "FactoryKit"),
                .external(name: "Afluent")
            ]
        ),
        .target(
            name: "\(featureName)Tests",
            destinations: [.mac, .iPhone],
            product: .unitTests,
            bundleId: "dev.eliudiaz.\(featureName)Tests",
            sources: "Tests/**",
            dependencies: [
                .target(name: featureName),
                .external(name: "FactoryTesting"),
                .external(name: "AfluentTesting")
            ]
        )
    ]
)
