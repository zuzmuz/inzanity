import SwiftTUI
import Foundation

struct ArrangerView: View {
    @ObservedObject var transport: Transport
    @ObservedObject var trackList: TrackList
    @ObservedObject var tempoTrack: TempoTrack

    var body: some View {
        HStack {
            VStack {
                Text("").frame(height: 2)
                Divider()
                TrackHeadListView(trackList: trackList)
            }.frame(width: 20)
            Divider()
            VStack {
                TimelineView(tempoTrack: tempoTrack,
                             zoom: transport.horizontalZoom,
                             offset: transport.horizontalOffset)
                Divider()
                TrackListView(trackList: trackList, zoom: transport.horizontalZoom)
            }

        }

    }
}

struct TrackHeadListView: View {
    @ObservedObject var trackList: TrackList

    var body: some View {
        VStack {
            ForEach(trackList.tracks) { track in
                TrackHeadView(track: track)
            }
        }
    }
}

struct TrackListView: View {
    @ObservedObject var trackList: TrackList
    var zoom: UInt16

    var body: some View {
        VStack {
            ForEach(trackList.tracks) { track in
                TrackView(track: track, zoom: zoom)
            }
        }
    }
}

struct TrackView: View {
    @ObservedObject var track: Track
    var zoom: UInt16

    var body: some View {
        HStack {
            ForEach(track.regions, id: \.position) { region in
                if !region.empty {
                    Text("".padding(
                        toLength: Int((region.duration * Double(zoom)).rounded()),
                        withPad: "█", startingAt: 0))
                }
            }
        }
    }
}

struct TimelineView: View {
    @ObservedObject var tempoTrack: TempoTrack
    var zoom: UInt16
    var offset: Double

    struct Measure {
        var number: UInt64
        var numerator: UInt16
        var denominator: UInt16
    }


    private func measures(width: Extended) -> [Measure] {
        var measures: [Measure] = []
        var measureNumber: UInt64 = 0
        var beatNumber: UInt64 = 0
        var accumulatedWidth: Double = 0
        
        for region in tempoTrack.regions {
            for _ in 0..<region.numberOfMeasures {
                measures.append(
                    Measure(
                        number: measureNumber,
                        numerator: region.numerator,
                        denominator: region.denominator
                    )
                )
                accumulatedWidth += Double(region.numerator) * Double(zoom) / Double(region.denominator)
                if Extended(Int(accumulatedWidth.rounded())) > width {
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
        }.frame(width: .init(Int((measure.numerator * zoom)/measure.denominator)))
    }
}

struct TrackHeadView: View {
    @ObservedObject var track: Track

    var body: some View {
        HStack {
            Text(track.name)
            Spacer()
            Text(String(format: "%.2f", track.volume))
            Button("M") {
                track.muted.toggle()
            }.background(track.muted ? Color.red : Color.default)
            Button("S") {
                track.solo.toggle()
            }.background(track.solo ? Color.yellow : Color.default)
        }
    }
}
