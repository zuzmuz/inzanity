import SwiftTUI

enum Event {
    case propagate(keyPress: KeyPress)

    // Display events
    case horizontalZoomIn(motion: UInt16)
    case horizontalZoomOut(motion: UInt16)
    case verticalZoomIn(motion: UInt16)
    case verticalZoomOut(motion: UInt16)
    case horizontalOffsetLeft(motion: UInt16)
    case horizontalOffsetRight(motion: UInt16)
    case verticalOffsetDown(motion: UInt16)
    case verticalOffsetUp(motion: UInt16)
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
            .horizontalOffsetLeft(motion: 1)
        case (.character("j"), []):
            .verticalOffsetDown(motion: 1)
        case (.character("k"), []):
            .verticalOffsetUp(motion: 1)
        case (.character("l"), []):
            .horizontalOffsetRight(motion: 1)
        case (.character("-"), []):
            .horizontalZoomOut(motion: 1)
        case (.character("="), []):
            .horizontalZoomIn(motion: 1)
        case (.character("_"), []):
            .verticalZoomOut(motion: 1)
        case (.character("+"), []):
            .verticalZoomIn(motion: 1)
        default:
            .propagate(keyPress: keyPress)
        }
    }
}
