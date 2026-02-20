import Foundation
import SwiftUI
import MapKit
import SwiftData
import PhotosUI

enum InteractionMode: String, CaseIterable {
    case browse = "ブラウズ"
    case addPoint = "地点追加"
    case drawBoundary = "エリア描画"
}

@Observable
final class FieldworkViewModel {
    var interactionMode: InteractionMode = .browse
    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var selectedPoint: SurveyPoint?
    var showPointDetail = false

    // Boundary drawing state
    var isDrawingBoundary = false
    var boundaryVertices: [CLLocationCoordinate2D] = []
    var showBoundaryNaming = false

    // New point state
    var pendingPointCoordinate: CLLocationCoordinate2D?
    var showNewPointEditor = false

    // Alert
    var alertMessage = ""
    var showAlert = false

    // Photo
    var selectedPhotoItems: [PhotosPickerItem] = []

    func handleMapTap(at coordinate: CLLocationCoordinate2D, modelContext: ModelContext) {
        switch interactionMode {
        case .browse:
            break
        case .addPoint:
            pendingPointCoordinate = coordinate
            showNewPointEditor = true
        case .drawBoundary:
            boundaryVertices.append(coordinate)
        }
    }

    func addSurveyPoint(
        title: String,
        note: String,
        category: String,
        modelContext: ModelContext
    ) {
        guard let coordinate = pendingPointCoordinate else { return }
        let point = SurveyPoint(
            title: title.isEmpty ? "地点 \(formattedDate())" : title,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            note: note,
            category: category
        )
        modelContext.insert(point)
        pendingPointCoordinate = nil
        showNewPointEditor = false
    }

    func finishBoundaryDrawing(name: String, note: String, modelContext: ModelContext) {
        guard boundaryVertices.count >= 3 else {
            alertMessage = "エリアを描画するには3点以上が必要です"
            showAlert = true
            return
        }
        let boundary = AreaBoundary(
            name: name.isEmpty ? "エリア \(formattedDate())" : name,
            coordinates: boundaryVertices,
            note: note
        )
        modelContext.insert(boundary)
        boundaryVertices = []
        isDrawingBoundary = false
        showBoundaryNaming = false
        interactionMode = .browse
    }

    func cancelBoundaryDrawing() {
        boundaryVertices = []
        isDrawingBoundary = false
        showBoundaryNaming = false
    }

    func deletePoint(_ point: SurveyPoint, modelContext: ModelContext) {
        // Delete associated photos from disk
        let fileManager = FileManager.default
        for fileName in point.photoFileNames {
            let url = Self.photoStorageURL.appendingPathComponent(fileName)
            try? fileManager.removeItem(at: url)
        }
        modelContext.delete(point)
    }

    func deleteBoundary(_ boundary: AreaBoundary, modelContext: ModelContext) {
        modelContext.delete(boundary)
    }

    func savePhoto(data: Data, for point: SurveyPoint) -> String? {
        let fileName = "\(point.id.uuidString)_\(UUID().uuidString).jpg"
        let url = Self.photoStorageURL.appendingPathComponent(fileName)

        do {
            try FileManager.default.createDirectory(
                at: Self.photoStorageURL,
                withIntermediateDirectories: true
            )
            try data.write(to: url)
            point.photoFileNames.append(fileName)
            return fileName
        } catch {
            alertMessage = "写真の保存に失敗しました: \(error.localizedDescription)"
            showAlert = true
            return nil
        }
    }

    func photoURL(for fileName: String) -> URL {
        Self.photoStorageURL.appendingPathComponent(fileName)
    }

    func deletePhoto(fileName: String, from point: SurveyPoint) {
        let url = Self.photoStorageURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
        point.photoFileNames.removeAll { $0 == fileName }
    }

    static var photoStorageURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FieldworkPhotos")
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: Date())
    }
}
