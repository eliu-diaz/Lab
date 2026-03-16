import ProjectDescription

let featureName = "PomoDuoTimer"

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
                .external(name: "FactoryKit")
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
                // According to the author, I shouldn't be importing FactoryKit in the Testing target, but given my current setup, I dunno of other way I can do this...
                .external(name: "FactoryTesting")
            ]
        )
    ]
)
