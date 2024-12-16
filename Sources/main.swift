import SwiftTUI
import SwiftyLua
import Foundation


struct ApplicationView: View {
    @State var transportState: TransportState = .init()
    @State var trackListState: [TrackState] = []
    var body: some View {
        VStack {
            TransportView(state: $transportState)
            Divider()
            ArrangerView(transportState: $transportState) //, trackListState: $trackListState)
        }
    }
}

let config = EnvironmentConfig(luaVM: LuaVM())
let app = Application(rootView: ApplicationView().environment(\.config, config))
app.start()

