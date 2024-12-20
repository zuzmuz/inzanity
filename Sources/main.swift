import Foundation
import SwiftTUI
import SwiftyLua

struct ApplicationView: View {
    @ObservedObject var project: Project
    var body: some View {
        VStack {
            TransportView(transport: project.transport)
            Divider()
            ArrangerView(transport:project.transport,
                         trackList: project.trackList,
                         tempoTrack: project.tempoTrack)
        }
    }
}

let config = EnvironmentConfig(luaVM: LuaVM())
let project = Project(id: UUID(), config: config)
let eventHandler = EventHandler(config: config)
let app = Application(rootView: ApplicationView(
        project: project
    ).environment(\.config, config)) { keyPress in
    
    return eventHandler.handle(keyPress: keyPress)
}
app.start()
