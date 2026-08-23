// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Clerk",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
    .macCatalyst(.v17),
    .macOS(.v14),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "ClerkKit", targets: ["ClerkKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/WeTransfer/Mocker", from: "3.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.1.0"),
  ],
  targets: [
    .target(
      name: "ClerkKit",
      dependencies: [],
      path: "Sources/ClerkKit",
      resources: [
        .process("Resources"),
      ],
      swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency"),
      ]
    ),
    .testTarget(
      name: "ClerkKitTests",
      dependencies: [
        "ClerkKit",
        .product(name: "Mocker", package: "Mocker"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
      ],
      path: "Tests",
      exclude: [
        "Domains/Organization/OrganizationAccountListDataSourceTests.swift",
        "UI",
      ],
      resources: [
        .process("Resources"),
      ],
      swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency"),
      ]
    ),
  ]
)
