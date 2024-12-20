import Foundation

class TrackList: ObservableObject {
    @Published var tracks: [Track] = []
}

class Track: Identifiable, ObservableObject {
    let id: UUID
    @Published var number: UInt
    @Published var name: String
    @Published var depth: Int = 0
    @Published var muted: Bool = false
    @Published var solo: Bool = false
    @Published var armed: Bool = false
    @Published var volume: Double = 0.0
    @Published var pan: Double = 0.0
    @Published var fxChain: FxChain = .init()
    @Published var items: [Item] = []

    init(id: UUID, number: UInt, name: String) {
        self.id = id
        self.number = number
        self.name = name
    }
}

struct FxChain {
    var bypassed: Bool = false
    var plugins: [Plugin] = []
}

protocol Item {}
protocol Plugin {}
