import SwiftTUI

struct ArrangerView: View {
    @Binding var transportState: TransportState
    @State var trackListState: [TrackState] = []
    var body: some View {
        VStack {
            ForEach(trackListState) { track in
                TrackView(track: track)
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
    var track: TrackState
    var body: some View {
        HStack {
            TextField(placeholder: "Track 1") { text in
                log("track name changed \(text)")
            }
        }
    }
}
