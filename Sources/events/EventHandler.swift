import SwiftTUI

enum Event {
    case propagate(keyPress: KeyPress)
    case horizontalZoomIn(motion: UInt16)
    case horizontalZoomOut(motion: UInt16)
}

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

    func handle(keyPress: KeyPress) -> Event {
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

    private func handleNormalMode(keyPress: KeyPress) -> Event {
        return switch (keyPress.key, keyPress.modifiers) {
        case (.character("h"), []):
            .propagate(keyPress: KeyPress(key: .left))
        case (.character("j"), []):
            .propagate(keyPress: KeyPress(key: .down))
        case (.character("k"), []):
            .propagate(keyPress: KeyPress(key: .up))
        case (.character("l"), []):
            .propagate(keyPress: KeyPress(key: .right))
        case (.character("-"), []):
            .horizontalZoomOut(motion: 1)
        case (.character("+"), []):
            .horizontalZoomIn(motion: 1)
        default:
            .propagate(keyPress: keyPress)
        }
    }
}
