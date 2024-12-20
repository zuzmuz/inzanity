import SwiftTUI
import Foundation

struct ArrangerView: View {
    @ObservedObject var transport: Transport
    @ObservedObject var trackList: TrackList
    @ObservedObject var tempoTrack: TempoTrack

    var body: some View {
        VStack {
            TimelineView(tempoTrack: tempoTrack, zoom: transport.horizontalZoom)
            Divider()
        }
    }
}

struct TimelineView: View {
    @ObservedObject var tempoTrack: TempoTrack
    var zoom: UInt16

    struct Measure {
        var number: UInt64
        var numerator: UInt16
        var denominator: UInt16
    }

    private func measures(width: Extended) -> [Measure] {
        var measures: [Measure] = []
        var measureNumber: UInt64 = 0
        var accumulatedWidth: Extended = .init(0)
        for region in tempoTrack.regions {
            for _ in 0..<region.numberOfMeasures {
                measures.append(
                    Measure(
                        number: measureNumber,
                        numerator: region.numerator,
                        denominator: region.denominator
                    )
                )
                accumulatedWidth = accumulatedWidth + .init(Int(region.numerator * zoom))
                if accumulatedWidth > width {
                    return measures
                }
                measureNumber += 1
            }
        }
        return measures
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                let measures = measures(width: geometry.width)
                ForEach(measures, id: \.number) { measure in
                    measureView(measure: measure)
                }
            }
        }.frame(height: 2)
    }

    func measureView(measure: Measure) -> some View {
        VStack {
            Text("\(measure.number)")
            Text("|")
        }.frame(width: .init(Int(measure.numerator * zoom)))
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
