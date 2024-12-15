import SwiftTUI

struct ApplicationView: View {
    @State var transportState: TransportState = .init()
    var body: some View {
        VStack {
            TransportView(state: $transportState)
        }
    }
}

Application(rootView: ApplicationView()).start()
