// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MedTranslate",
    platforms: [.macOS(.v15)],
    products: [.executable(name: "MedTranslate", targets: ["MedTranslate"])],
    targets: [.executableTarget(name: "MedTranslate", path: "MedTranslate/Sources/MedTranslate")]
)
