import SwiftTUI

struct ArrangerView: View {
    @Binding var transportState: TransportState
    var body: some View {
        VStack {
            Text("Arranger")
            HStack {
                Button("Play") {
                    transportState.isPlaying.toggle()
                }
                Button("Stop") {
                    transportState.isPlaying = false
                }
            }
        }
    }
}
