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
    /// the horizontal zoom represents how many character represents a whole note
    @Published var horizontalZoom: UInt16 = 1
    @Published var verticalZoom: UInt16 = 1
    /// the horizontal offset represents how many whole notes are scrolled
    @Published private(set) var horizontalOffset: Double = 0
    @Published private(set) var verticalOffset: Double = 0

    func modifyHorizontalOffset(by motion: Int16) {
        horizontalOffset += Double(motion) / Double(self.horizontalZoom)
    }

    func modifyVerticalOffset(by motion: Int16) {
        verticalOffset += Double(motion) / Double(self.verticalOffset)
    }
}
