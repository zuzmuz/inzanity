import Foundation

final class TrackList: ObservableObject {
    @Published var tracks: [Track]

    init(tracks: [Track] = []) {
        self.tracks = tracks
    }
}

final class Track: Identifiable, ObservableObject {

    final class Item: BoundedEventItem, ObservableObject {
        @Published var position: Tick
        @Published var duration: Tick
        var source: Source

        enum Source {
            case midi(MidiItem)
            case audio(AudioItem)
            case pattern
            case automation
        }

        init(position: Tick, duration: Tick, source: Source) {
            self.position = position
            self.duration = duration
            self.source = source
        }
    }

    var regions: [(
            position: Tick,
            duration: Tick,
            empty: Bool
        )] {
        #warning("consider caching")
        var lastEnd: Tick = Tick(value: 0)
        var regions:[(
            position: Tick,
            duration: Tick,
            empty: Bool
        )] = []

        for item in items {
            if item.position > lastEnd {
                regions.append((
                    position: lastEnd,
                    duration: item.position - lastEnd,
                    empty: true
                ))
            }
            regions.append((
                position: item.position,
                duration: item.duration,
                empty: false
            ))
            lastEnd = item.position + item.duration
        }
        return regions
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
        volume: Double = 0,
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

struct MidiItem {
    var midiData: Data
}

struct AudioItem {
    var fileLocation: String
    var positionInFile: TimeInterval
}

protocol Plugin {}
