import AppKit
import ApplicationServices
import UsheretteCore

/// Finds and clicks other apps' menu bar icons through the Accessibility API.
///
/// This is the only file allowed to use that API (ADR 0003); `scripts/lint.sh` checks it.
/// It reads which apps have an icon and nothing else: no titles, no menu contents, no windows.
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
