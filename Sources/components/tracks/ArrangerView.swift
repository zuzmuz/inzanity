import SwiftTUI

struct ArrangerView: View {
    @Binding var transportState: TransportState
    @Binding var trackListState: [TrackState]
    var body: some View {
        VStack {
            ForEach(Array(trackListState.indices), id: \.self) { index in
                TrackView(track: $trackListState[index])
            }
            addTackButton
        }
    }

    var addTackButton: some View {
        Button("Add Track") {
            log("add track pressed")
            trackListState.append(.init())
        }
    }
}

struct TrackView: View {
    @Binding var track: TrackState
    @State var renaming: Bool = false
    var trackName: String {
        if track.name.isEmpty {
            return "track \(track.number)"
        } else {
            return track.name
        }
    }
    var body: some View {
        HStack {
            if renaming {
                TextField(placeholder: trackName) { text in
                    track.name = text
                    renaming = false
                }
            } else {
                Button(trackName) { 
                    renaming = true
                }
            }
        }
    }
}
