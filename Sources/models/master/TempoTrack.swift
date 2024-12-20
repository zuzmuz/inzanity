import Foundation

class TempoTrack: ObservableObject {

    @Published private(set) var tempoChanges: [TempoChange] = []
    @Published private(set) var timeSignatureChanges: [TimeSignatureChange] = []

    var regions: [(position: Tick,
                   numerator: UInt16,
                   denominator: UInt16,
                   numberOfMeasures: UInt64)] {

        #warning("consider caching")

        var timeSignatureChanges = self.timeSignatureChanges
        guard let last = timeSignatureChanges.last else {
            return [(0, 4, 4, .max)]
        }

        timeSignatureChanges.append(
            TimeSignatureChange(
                position: .max,
                numerator: last.numerator,
                denominator: last.denominator
            )
        )
        return zip(timeSignatureChanges, timeSignatureChanges.dropFirst()).map { current, next in
            return (
                current.position,
                current.numerator,
                current.denominator,
                (next.position - current.position).beats(
                    denominator: current.denominator
                ) / UInt64(current.numerator)
            )
        }
    }

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
                denominator: 4),
            TimeSignatureChange(
                position: 12 * ticksPerWholeNote,
                numerator: 5,
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
