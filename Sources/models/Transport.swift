import SwiftTUI
import Foundation

class Transport: ObservableObject {
    @Published var currentCursorPosition: Double = 0
    @Published var startCursorPosition: Double = 0
    @Published var loopStartPosition: Double = 0
    @Published var loopEndPosition: Double = 0
    @Published var playing: Bool = false
    @Published var recording: Bool = false
    @Published var looping: Bool = false
    @Published var horizontalZoom: UInt16 = 1
}
