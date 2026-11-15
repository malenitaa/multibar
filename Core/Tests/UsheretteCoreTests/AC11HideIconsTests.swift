import Testing

@testable import UsheretteCore

// AC-11 · Hide the icons on the left of the marker (SPEC.md, section 5).
@Suite("AC-11 · Hide icons behind the marker")
struct AC11HideIconsTests {
    @Test("given hiding is off, when I turn it on and off again, then each choice is saved")
    func togglesAndSaves() throws {
        let store = InMemoryConfigStore()
        let setIconHiding = SetIconHiding(store: store)

        let on = try setIconHiding(true, in: .empty)
        #expect(on.hidesIcons)
        #expect(store.saved?.hidesIcons == true)

        let off = try setIconHiding(false, in: on)
        #expect(!off.hidesIcons)
        #expect(store.saved?.hidesIcons == false)
    }

    @Test("given a new configuration, when nothing was chosen, then icons are not hidden")
    func offByDefault() {
        #expect(!Configuration.empty.hidesIcons)
    }

    @Test("given the marker on the right of the notch, when hiding, then its left edge ends up well past the notch")
    func reachesPastTheNotch() throws {
        // Measured on a 14-inch MacBook: marker ending at 1134, notch ending at 848, 16 pt of padding.
        let length = try #require(HidingGeometry.hidingLength(markerRightEdge: 1134, markerPadding: 16, notchRightEdge: 848))

        let leftEdge = 1134 - (length + 16)
        #expect(leftEdge == 848 - HidingGeometry.overshoot)
    }

    @Test("given a display without a notch, when hiding, then there is no length that works")
    func noNotch() {
        #expect(HidingGeometry.hidingLength(markerRightEdge: 1134, markerPadding: 16, notchRightEdge: nil) == nil)
    }

    @Test("given the marker is not on the right of the notch, when hiding, then there is no length that works")
    func markerOnTheWrongSide() {
        #expect(HidingGeometry.hidingLength(markerRightEdge: 600, markerPadding: 16, notchRightEdge: 848) == nil)
    }
}
