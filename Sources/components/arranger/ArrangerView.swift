import SwiftTUI
import Foundation

struct ArrangerView: View {
    @ObservedObject var transport: Transport
    @ObservedObject var trackList: TrackList
    @ObservedObject var tempoTrack: TempoTrack

    var body: some View {
        VStack {
            TimelineView(tempoTrack: tempoTrack)
        }
    }
}

struct TimelineView: View {
    @ObservedObject var tempoTrack: TempoTrack

    struct Measure: Identifiable {
        var id: UUID = UUID()
        var numerator: UInt16
        var denominator: UInt16
    }

    var measures: [Measure] {
        return zip(tempoTrack.timeSignatureChanges,
                   tempoTrack.timeSignatureChanges.dropFirst())
            .reduce(into: []) { (acc, pair) in
                let (current, next) = pair
                let numberOfMeasures = (next.beatPosition(subdivision: current.denominator) -
                                        current.beatPosition(subdivision: current.denominator)) / 
                                        UInt64(current.numerator)
                acc.append(contentsOf: Array(repeating: .init(numerator: current.numerator,
                                                              denominator: current.denominator),
                                             count: Int(numberOfMeasures)))
            }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                ForEach(measures) { measure in
                    MeasureView(numerator: measure.numerator, denominator: measure.denominator)
                }

            }
        }.frame(height: 2).border()
    }
}

struct MeasureView: View {
    var numerator: UInt16
    var denominator: UInt16

    var body: some View {
        VStack {
            Text("\(numerator)/\(denominator)")
        }
    }
}

struct TrackHeadView: View {
    var track: Track

    var body: some View {
        HStack {
            Button(track.name) {
            }
        }
    }
}
