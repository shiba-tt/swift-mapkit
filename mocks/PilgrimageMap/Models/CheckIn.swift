import Foundation

/// チェックイン記録
struct CheckIn: Identifiable, Codable {
    let id: UUID
    let spotID: UUID
    let spotName: String
    let workTitle: String
    let date: Date
    let note: String

    init(
        id: UUID = UUID(),
        spotID: UUID,
        spotName: String,
        workTitle: String,
        date: Date = Date(),
        note: String = ""
    ) {
        self.id = id
        self.spotID = spotID
        self.spotName = spotName
        self.workTitle = workTitle
        self.date = date
        self.note = note
    }
}
