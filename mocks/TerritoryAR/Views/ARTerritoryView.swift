import SwiftUI
import ARKit
import RealityKit
import CoreLocation

// MARK: - AR Territory View

struct ARTerritoryView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    @State private var showARUnavailable = false

    var body: some View {
        ZStack {
            if ARWorldTrackingConfiguration.isSupported {
                ARTerritoryViewRepresentable(
                    gameManager: gameManager,
                    locationManager: locationManager
                )
                .ignoresSafeArea()
            } else {
                arUnavailableView
            }

            // AR HUD Overlay
            VStack {
                arTopBar
                Spacer()
                arZoneIndicators
            }
            .padding()
        }
    }

    // MARK: - AR Unavailable Fallback

    private var arUnavailableView: some View {
        VStack(spacing: 20) {
            Image(systemName: "arkit")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("AR機能は利用できません")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("このデバイスはARWorldTrackingに\n対応していません")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)

            // Show nearby zones info instead
            if !gameManager.nearbyZones.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("近くのゾーン")
                        .font(.headline)
                        .foregroundStyle(.white)

                    ForEach(gameManager.nearbyZones) { zone in
                        nearbyZoneRow(zone)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gameBackground)
    }

    private func nearbyZoneRow(_ zone: GameZone) -> some View {
        HStack {
            Circle()
                .fill(zone.ownerTeam?.color ?? .gray)
                .frame(width: 12, height: 12)
            Text(zone.name)
                .foregroundStyle(.white)
            Spacer()
            if let team = zone.ownerTeam {
                Text(team.displayName)
                    .font(.caption)
                    .foregroundStyle(team.color)
            } else {
                Text("中立")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Text("\(zone.pointsValue)pt")
                .font(.caption.bold())
                .foregroundStyle(.yellow)
        }
    }

    // MARK: - AR HUD

    private var arTopBar: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "camera.viewfinder")
                Text("ARモード")
                    .font(.caption.bold())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            if let heading = locationManager.heading {
                HStack(spacing: 4) {
                    Image(systemName: "location.north.fill")
                        .rotationEffect(.degrees(-heading.magneticHeading))
                    Text(compassDirection(heading.magneticHeading))
                        .font(.caption.bold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private var arZoneIndicators: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(gameManager.nearbyZones) { zone in
                    arZoneChip(zone)
                }
            }
        }
    }

    private func arZoneChip(_ zone: GameZone) -> some View {
        let distance = distanceToZone(zone)

        return VStack(spacing: 4) {
            Image(systemName: zone.ownerTeam?.icon ?? "mappin.circle.fill")
                .font(.title3)
                .foregroundStyle(zone.ownerTeam?.color ?? .gray)

            Text(zone.name)
                .font(.caption2.bold())
                .foregroundStyle(.white)

            if let dist = distance {
                Text("\(Int(dist))m")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func distanceToZone(_ zone: GameZone) -> CLLocationDistance? {
        guard let location = locationManager.currentLocation else { return nil }
        let zoneCenter = zone.shape.centerCoordinate
        let zoneLoc = CLLocation(latitude: zoneCenter.latitude, longitude: zoneCenter.longitude)
        return location.distance(from: zoneLoc)
    }

    private func compassDirection(_ heading: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((heading + 22.5) / 45.0) & 7
        return directions[index]
    }
}

// MARK: - AR View Representable

struct ARTerritoryViewRepresentable: UIViewRepresentable {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        config.planeDetection = [.horizontal]

        arView.session.run(config)
        arView.session.delegate = context.coordinator

        context.coordinator.arView = arView

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        context.coordinator.updateZoneAnchors(
            zones: gameManager.nearbyZones,
            playerLocation: locationManager.currentLocation,
            playerHeading: locationManager.heading
        )
    }

    func makeCoordinator() -> ARCoordinator {
        ARCoordinator()
    }

    // MARK: - AR Coordinator

    final class ARCoordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        private var zoneEntities: [UUID: AnchorEntity] = [:]

        func updateZoneAnchors(
            zones: [GameZone],
            playerLocation: CLLocation?,
            playerHeading: CLHeading?
        ) {
            guard let arView = arView,
                  let playerLoc = playerLocation else { return }

            // Remove old anchors
            let currentZoneIDs = Set(zones.map(\.id))
            for (id, anchor) in zoneEntities where !currentZoneIDs.contains(id) {
                arView.scene.removeAnchor(anchor)
                zoneEntities.removeValue(forKey: id)
            }

            let headingRad = (playerHeading?.magneticHeading ?? 0) * .pi / 180

            for zone in zones {
                let zoneCenter = zone.shape.centerCoordinate
                let zoneLoc = CLLocation(latitude: zoneCenter.latitude, longitude: zoneCenter.longitude)
                let distance = playerLoc.distance(from: zoneLoc)

                // Only show zones within 200m in AR
                guard distance < 200 else {
                    if let anchor = zoneEntities[zone.id] {
                        arView.scene.removeAnchor(anchor)
                        zoneEntities.removeValue(forKey: zone.id)
                    }
                    continue
                }

                let bearing = bearingBetween(
                    from: playerLoc.coordinate,
                    to: zoneCenter
                )

                // Calculate relative angle from device heading
                let relativeAngle = bearing - headingRad
                let scaledDistance = min(Float(distance) * 0.1, 15.0) // Scale down for AR

                let x = Float(sin(relativeAngle)) * scaledDistance
                let z = -Float(cos(relativeAngle)) * scaledDistance
                let y: Float = -1.0

                if let existingAnchor = zoneEntities[zone.id] {
                    existingAnchor.position = SIMD3(x, y, z)
                    updateZoneEntity(existingAnchor, zone: zone)
                } else {
                    let anchor = AnchorEntity(world: SIMD3(x, y, z))
                    addZoneVisualization(to: anchor, zone: zone, distance: distance)
                    arView.scene.addAnchor(anchor)
                    zoneEntities[zone.id] = anchor
                }
            }
        }

        private func addZoneVisualization(to anchor: AnchorEntity, zone: GameZone, distance: CLLocationDistance) {
            let color: UIColor = zone.ownerTeam?.uiColor ?? .systemGray

            // Base platform
            let platformSize: Float = 0.5
            let platform = ModelEntity(
                mesh: .generateCylinder(height: 0.05, radius: platformSize),
                materials: [SimpleMaterial(color: color.withAlphaComponent(0.6), isMetallic: false)]
            )
            anchor.addChild(platform)

            // Zone pillar / beacon
            let pillarHeight: Float = 0.8
            let pillar = ModelEntity(
                mesh: .generateCylinder(height: pillarHeight, radius: 0.08),
                materials: [SimpleMaterial(color: color.withAlphaComponent(0.8), isMetallic: true)]
            )
            pillar.position.y = pillarHeight / 2
            anchor.addChild(pillar)

            // Top sphere indicator
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.12),
                materials: [SimpleMaterial(color: color, isMetallic: true)]
            )
            sphere.position.y = pillarHeight + 0.12
            anchor.addChild(sphere)

            // Capture ring (if being captured)
            if zone.isBeingCaptured {
                let ring = ModelEntity(
                    mesh: .generateCylinder(height: 0.02, radius: platformSize + 0.1),
                    materials: [SimpleMaterial(color: .white.withAlphaComponent(0.5), isMetallic: false)]
                )
                ring.position.y = 0.06
                anchor.addChild(ring)
            }
        }

        private func updateZoneEntity(_ anchor: AnchorEntity, zone: GameZone) {
            let color: UIColor = zone.ownerTeam?.uiColor ?? .systemGray

            // Update materials of existing children
            for child in anchor.children {
                if var model = child as? HasModel,
                   let existingMaterial = model.model?.materials.first as? SimpleMaterial {
                    var newMaterial = SimpleMaterial()
                    newMaterial.color = .init(tint: color.withAlphaComponent(CGFloat(existingMaterial.color.tint.cgColor.alpha)))
                    newMaterial.metallic = existingMaterial.metallic
                    model.model?.materials = [newMaterial]
                }
            }
        }

        private func bearingBetween(
            from: CLLocationCoordinate2D,
            to: CLLocationCoordinate2D
        ) -> Double {
            let lat1 = from.latitude * .pi / 180
            let lat2 = to.latitude * .pi / 180
            let dLon = (to.longitude - from.longitude) * .pi / 180

            let y = sin(dLon) * cos(lat2)
            let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

            return atan2(y, x)
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            // AR session error handling is managed by the view
        }
    }
}
