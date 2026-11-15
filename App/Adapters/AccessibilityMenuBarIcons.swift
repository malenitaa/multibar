import AppKit
import ApplicationServices
import UsheretteCore

/// Finds, clicks and moves other apps' menu bar icons through the Accessibility API.
///
/// This is the only file allowed to use that API or to post input events (ADR 0003);
/// `scripts/lint.sh` checks it. It reads which apps have an icon and where it is, and nothing
/// else: no titles, no menu contents, no windows.
@MainActor
final class AccessibilityMenuBarIcons: MenuBarIcons {
    /// The windows each app had on screen just before its icon was clicked.
    private var windowsBeforeClick: [String: Set<CGWindowID>] = [:]

    var isPermitted: Bool {
        AXIsProcessTrusted()
    }

    func requestPermission() {
        _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
    }

    func runningApps() -> [MenuBarApp] {
        guard isPermitted else { return [] }
        var seen = Set<String>()
        return NSWorkspace.shared.runningApplications
            .compactMap { app -> MenuBarApp? in
                guard app.processIdentifier != ProcessInfo.processInfo.processIdentifier,
                    let bundleID = app.bundleIdentifier, seen.insert(bundleID).inserted,
                    icon(of: app) != nil
                else { return nil }
                return MenuBarApp(bundleID: bundleID, name: app.localizedName ?? bundleID)
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func hasIcon(bundleID: String) -> Bool {
        isPermitted && runningApp(bundleID).flatMap(icon(of:)) != nil
    }

    func openMenu(bundleID: String) -> Bool {
        guard isPermitted, let app = runningApp(bundleID), let icon = icon(of: app) else { return false }
        windowsBeforeClick[bundleID] = windowsOnScreen(of: app)
        return AXUIElementPerformAction(icon, kAXPressAction as CFString) == .success
    }

    func isMenuOpen(bundleID: String) -> Bool {
        guard let app = runningApp(bundleID), let before = windowsBeforeClick[bundleID] else { return false }
        return !windowsOnScreen(of: app).subtracting(before).isEmpty
    }

    func iconFrame(bundleID: String) -> ClosedRange<Double>? {
        guard isPermitted, let frame = runningApp(bundleID).flatMap(icon(of:)).flatMap(frame(of:)) else { return nil }
        return Double(frame.minX)...Double(frame.maxX)
    }

    /// The same gesture a person makes to rearrange the menu bar: hold ⌘, press on the icon,
    /// slide sideways and let go. The pointer is put back where it was.
    func dragIcon(bundleID: String, toX x: Double) -> Bool {
        guard isPermitted, let app = runningApp(bundleID), let frame = icon(of: app).flatMap(frame(of:)) else { return false }
        let start = CGPoint(x: frame.midX, y: frame.midY)
        // Icon positions lag behind while the bar rearranges itself. Pressing on a stale
        // position would drag whichever icon is there now, so check whose icon it is first.
        guard owner(of: start) == app.processIdentifier else { return false }
        let end = CGPoint(x: x, y: frame.midY)
        let pointerBefore = CGEvent(source: nil)?.location
        let source = CGEventSource(stateID: .hidSystemState)
        func post(_ type: CGEventType, at point: CGPoint, thenWait microseconds: useconds_t) {
            let event = CGEvent(mouseEventSource: source, mouseType: type, mouseCursorPosition: point, mouseButton: .left)
            event?.flags = .maskCommand
            event?.post(tap: .cghidEventTap)
            usleep(microseconds)
        }

        post(.leftMouseDown, at: start, thenWait: 150_000)
        let steps = 20
        for step in 1...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            post(.leftMouseDragged, at: CGPoint(x: start.x + (end.x - start.x) * progress, y: start.y), thenWait: 20_000)
        }
        usleep(130_000)
        post(.leftMouseUp, at: end, thenWait: 0)
        if let pointerBefore {
            CGWarpMouseCursorPosition(pointerBefore)
        }
        return true
    }

    private func runningApp(_ bundleID: String) -> NSRunningApplication? {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first
    }

    /// The app's first item in the status area of the menu bar, if it has one.
    private func icon(of app: NSRunningApplication) -> AXUIElement? {
        let element = AXUIElementCreateApplication(app.processIdentifier)
        // An app that is not answering must not freeze Usherette.
        AXUIElementSetMessagingTimeout(element, 0.25)
        guard let extras = attribute("AXExtrasMenuBar", of: element), CFGetTypeID(extras) == AXUIElementGetTypeID(),
            let items = attribute(kAXChildrenAttribute, of: extras as! AXUIElement) as? [AXUIElement]
        else { return nil }
        return items.first { attribute(kAXRoleAttribute, of: $0) as? String == "AXMenuBarItem" }
    }

    /// The process whose interface is at a point on screen.
    private func owner(of point: CGPoint) -> pid_t? {
        let systemWide = AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(systemWide, 0.5)
        var element: AXUIElement?
        guard AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element) == .success, let element else { return nil }
        var pid: pid_t = 0
        return AXUIElementGetPid(element, &pid) == .success ? pid : nil
    }

    /// Where an icon is on screen, with the origin at the top left as input events expect.
    private func frame(of icon: AXUIElement) -> CGRect? {
        guard let position = attribute(kAXPositionAttribute, of: icon), let size = attribute(kAXSizeAttribute, of: icon),
            CFGetTypeID(position) == AXValueGetTypeID(), CFGetTypeID(size) == AXValueGetTypeID()
        else { return nil }
        var origin = CGPoint.zero
        var extent = CGSize.zero
        guard AXValueGetValue(position as! AXValue, .cgPoint, &origin), AXValueGetValue(size as! AXValue, .cgSize, &extent) else { return nil }
        return CGRect(origin: origin, size: extent)
    }

    private func attribute(_ name: String, of element: AXUIElement) -> AnyObject? {
        var value: AnyObject?
        return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
    }

    /// Window numbers only: no titles or contents, so this needs no Screen Recording.
    private func windowsOnScreen(of app: NSRunningApplication) -> Set<CGWindowID> {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        return Set(
            windows.compactMap { window in
                guard window[kCGWindowOwnerPID as String] as? pid_t == app.processIdentifier else { return nil }
                return window[kCGWindowNumber as String] as? CGWindowID
            }
        )
    }
}
