import Foundation

class Project: Identifiable, ObservableObject {
    let id: UUID
    var metadata: Metadata
    @Published var trackList: TrackList
    @Published var transport: Transport
    @Published var tempoTrack: TempoTrack

    struct Metadata {
        var name: String
    }

    init(id: UUID, config: EnvironmentConfig) {
        self.id = id
        metadata = Metadata(name: "Untitled")
        trackList = TrackList()
        transport = Transport()
        tempoTrack = TempoTrack(
            tempoConfig: config.tempo,
            timeSignatureConfig: config.timeSignature
        )
    }

    init(load from: URL) {
        fatalError("Not implemented")
    }
}
