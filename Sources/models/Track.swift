import Foundation

final class TrackList: ObservableObject {
    @Published var tracks: [Track]

    init(tracks: [Track] = []) {
        self.tracks = tracks
    }
}

final class Track: Identifiable, ObservableObject {

    enum Item {
        case midi(MidiItem)
        case audio(AudioItem)
        // case automation(AutomationItem)
    }

    let id: UUID
    @Published var number: UInt
    @Published var name: String
    @Published var depth: Int
    @Published var muted: Bool
    @Published var solo: Bool
    @Published var armed: Bool
    @Published var volume: Double
    @Published var pan: Double
    @Published var fxChain: FxChain
    @Published var items: [Item]

    init(
        id: UUID,
        number: UInt,
        name: String,
        depth: Int = 0,
        muted: Bool = false,
        solo: Bool = false,
        armed: Bool = false,
        volume: Double = 1,
        pan: Double = 0,
        fxChain: FxChain = FxChain(),
        items: [Item] = []
    ) {
        self.id = id
        self.number = number
        self.name = name
        self.depth = depth
        self.muted = muted
        self.solo = solo
        self.armed = armed
        self.volume = volume
        self.pan = pan
        self.fxChain = fxChain
        self.items = items
    }
}

final class FxChain: ObservableObject {
    @Published var bypassed: Bool = false
    @Published var plugins: [Plugin] = []
}

final class MidiItem: BoundedEventItem, ObservableObject {
    @Published var position: Tick
    @Published var duration: Tick

    var midiData: Data

    init(position: Tick, duration: Tick, midiData: Data) {
        self.position = position
        self.duration = duration
        self.midiData = midiData
    }
}

final class AudioItem: BoundedEventItem {
    var channels: UInt8
    @Published var position: Tick
    @Published var duration: Tick

    var url: URL
    var positionInFile: TimeInterval

    init(
        channels: UInt8, position: Tick, duration: Tick, url: URL, positionInFile: TimeInterval
    ) {
        self.channels = channels
        self.position = position
        self.duration = duration
        self.url = url
        self.positionInFile = positionInFile
    }
}

// class AutomationItem: BoundedEventItem {
//     var position: Tick
//     var duration: Tick
// }

protocol Plugin {}
