import Foundation

final class Project: Identifiable, ObservableObject {
    let id: UUID
    var url: URL?
    @Published var metadata: Metadata
    @Published var tempoTrack: TempoTrack
    @Published var trackList: TrackList
    @Published var transport: Transport

    struct Metadata {
        var name: String
        var author: String?
        var description: String?
        var createdDate: Date = Date()
        var changedDate: Date = Date()
        var tags: [String]?
    }

    init(
        id: UUID,
        metadata: Metadata,
        tempoTrack: TempoTrack,
        trackList: TrackList,
        transport: Transport = Transport()
    ) {
        self.id = id
        self.metadata = metadata
        self.trackList = trackList
        self.transport = transport
        self.tempoTrack = tempoTrack
    }

    convenience init(id: UUID, config: EnvironmentConfig) {
        self.init(
            id: id,
            metadata: Metadata(name: "Untitled", createdDate: Date(), changedDate: Date()),
            tempoTrack: TempoTrack(
                tempoConfig: config.tempo,
                timeSignatureConfig: config.timeSignature
            ),
            trackList: TrackList(),
            transport: Transport())
    }
}
