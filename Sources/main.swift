import SwiftTUI
import SwiftyLua
import Foundation


struct ApplicationView: View {
    let luaVM = LuaVM()

    @State var transportState: TransportState = .init()
    var body: some View {
        VStack {
            TransportView(state: $transportState)
            ArrangerView(transportState: $transportState)
        }.onAppear {
            if let url = URL.init("scripts/main.lua") {
                do {
                    switch try luaVM.execute(url: url) {
                        case let .values(values):
                            for value in values {
                                log(value)
                            }
                    case let .error(error): 
                        log("Lua Error: \(error)")
                    }
                } catch {
                    log("Error: \(error)")
                }
            }
        }
    }
}

Application(rootView: ApplicationView()).start()
