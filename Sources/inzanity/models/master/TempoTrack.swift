import Foundation

final class TempoTrack: ObservableObject {

    @Published private(set) var tempoChanges: [TempoChange] = []
    @Published private(set) var timeSignatureChanges: [TimeSignatureChange] = []

    var regions:
        [(
            position: Tick,
            numerator: UInt16,
            denominator: UInt16,
            numberOfMeasures: UInt64
        )]
    {

        #warning("consider caching")

        var timeSignatureChanges = self.timeSignatureChanges
        guard let last = timeSignatureChanges.last else {
            return [(Tick(value: 0), 4, 4, .max)]
        }

        timeSignatureChanges.append(
            TimeSignatureChange(
                position: Tick(value: .max),
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

    init(tempoChanges: [TempoChange], timeSignatureChanges: [TimeSignatureChange]) {
        self.tempoChanges = tempoChanges
        self.timeSignatureChanges = timeSignatureChanges
    }

    init(
        tempoConfig: EnvironmentConfig.Tempo,
        timeSignatureConfig: EnvironmentConfig.TimeSignature
    ) {

        tempoChanges = [
            TempoChange(
                position: Tick(value: 0),
                tempo: Tempo(bpm: tempoConfig.bpm, denominator: .quarter))
        ]
        timeSignatureChanges = [
            TimeSignatureChange(
                position: Tick(value: 0),
                numerator: timeSignatureConfig.numerator,
                denominator: timeSignatureConfig.denominator),
        ]
    }

    func add(tempoChange: TempoChange) {
        tempoChanges.append(tempoChange)
        tempoChanges.sort { $0.position.value < $1.position.value }
    }

    private func getTime(from position: Tick) -> TimeInterval {
        var result: TimeInterval = 0
        for (current, next) in zip(tempoChanges, tempoChanges.dropFirst()) {
            if next.position <= position {
                switch current.ramp {
                case .jump:
                    result += (next.position - current.position).seconds(with: current.tempo)
                case .linear:
                    fatalError("Linear curves not implemented")
                case .bezier:
                    fatalError("Bezier curves not implemented")
                }
            } else if current.position <= position {
                switch current.ramp {
                case .jump:
                    result += (position - current.position).seconds(with: current.tempo)
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
    var tempo: Tempo
    var ramp: Curve = .linear

    init(position: Tick, tempo: Tempo) {
        self.position = position
        self.tempo = tempo
    }
}

struct TimeSignatureChange: EventItem {
    var position: Tick
    var numerator: UInt16
    var denominator: UInt16
}
