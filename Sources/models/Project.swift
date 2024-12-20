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

typealias Tick = UInt64
typealias SecondsPerWholeNote = Double

let ticksPerWholeNote: Tick = 1 << 20

func time(from position: Tick, with tempo: SecondsPerWholeNote) -> TimeInterval {
    return tempo * TimeInterval(position) / TimeInterval(ticksPerWholeNote)
}

class TempoTrack: ObservableObject {

    @Published private(set) var tempoChanges: [TempoChange] = []
    @Published private(set) var timeSignatureChanges: [TimeSignatureChange] = []

    init(
        tempoConfig: EnvironmentConfig.Tempo,
        timeSignatureConfig: EnvironmentConfig.TimeSignature
    ) {

        tempoChanges = [
            TempoChange(position: 0, bpm: tempoConfig.bpm)
        ]
        timeSignatureChanges = [
            TimeSignatureChange(
                position: 0,
                numerator: timeSignatureConfig.numerator,
                denominator: timeSignatureConfig.denominator),
            TimeSignatureChange(
                position: 4 * ticksPerWholeNote,
                numerator: 3,
                denominator: 4)
        ]
    }

    func add(tempoChange: TempoChange) {
        tempoChanges.append(tempoChange)
        tempoChanges.sort { $0.position < $1.position }
    }

    private func getTime(from position: UInt64) -> TimeInterval {
        var result: TimeInterval = 0
        for (current, next) in zip(tempoChanges, tempoChanges.dropFirst()) {
            if next.position <= position {
                switch current.ramp {
                case .jump:
                    result += time(from: next.position - current.position, 
                                                               with: current.tempo)
                case .linear:
                    fatalError("Linear curves not implemented")
                case .bezier:
                    fatalError("Bezier curves not implemented")
                }
            } else if current.position <= position {
                switch current.ramp {
                case .jump:
                    result += time(from: position - current.position,
                                                               with: current.tempo)
                case .linear:
                    fatalError("Linear curves not implemented")
                case .bezier:
                    fatalError("Bezier curves not implemented")
                }
            }
        }

        return result
    }
}

enum Curve {
    case jump
    case linear
    case bezier
}

struct TempoChange: EventItem {
    var position: Tick
    var tempo: SecondsPerWholeNote
    var ramp: Curve = .linear

    init(position: Tick, bpm: Double) {
        self.position = position
        self.tempo = 4 * 60 / bpm
    }

    init(position: Tick, tempo: SecondsPerWholeNote) {
        self.position = position
        self.tempo = tempo
    }

    var bpm: Double {
        return 4 * 60 / tempo
    }
}

struct TimeSignatureChange: EventItem {
    var position: Tick
    var numerator: UInt16
    var denominator: UInt16
}

protocol EventItem {
    /// Position in ticks, which is a 2^20 of a whole note
    var position: Tick { get set }
}

extension EventItem {
    func beatPosition(subdivision: UInt16) -> UInt64 {
        return self.position * UInt64(subdivision) / ticksPerWholeNote
    }
}
