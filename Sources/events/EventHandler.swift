import SwiftTUI

class EventHandler {
    enum Mode {
        case normal
        case insert
        case command
        case visual
    }

    var config: EnvironmentConfig
    var mode: Mode = .normal

    init(config: EnvironmentConfig) {
        self.config = config
    }

    func handle(keyPress: KeyPress) -> Application.InputHandled {
        switch mode {
        case .normal:
            return handleNormalMode(keyPress: keyPress)
        // case .insert:
        //     handleInsertMode(keyPress: keyPress)
        default:
            break
        }
        return .propagate(keyPress: keyPress)
    }

    private func handleNormalMode(keyPress: KeyPress) -> Application.InputHandled {
        return switch (keyPress.key, keyPress.modifiers) {
        case (.character("h"), []):
            .propagate(keyPress: KeyPress(key: .left))
        case (.character("j"), []):
            .propagate(keyPress: KeyPress(key: .down))
        case (.character("k"), []):
            .propagate(keyPress: KeyPress(key: .up))
        case (.character("l"), []):
            .propagate(keyPress: KeyPress(key: .right))
        default:
            .propagate(keyPress: keyPress)
        }
    }
}
