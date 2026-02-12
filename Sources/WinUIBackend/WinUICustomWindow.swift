import CWinRT
import Foundation
import SwiftCrossUI
import UWP
import WinAppSDK
import WinSDK
import WinUI
import WinUIInterop
import WindowsFoundation

public class CustomWindow: WinUI.Window {
    public typealias Widget = WinUIBackend.Widget
    /// Hardcoded menu bar height from MenuBar_themeresources.xaml in the
    /// microsoft-ui-xaml repository.
    static let menuBarHeight = 0

    var menuBar = WinUI.MenuBar()
    var child: WinUIBackend.Widget?
    var grid: WinUI.Grid
    var cachedAppWindow: WinAppSDK.AppWindow!

    var scaleFactor: Double {
        // I'm leaving this code here for future travellers. Be warned that this always
        // seems to return 100% even if the scale factor is set to 125% in settings.
        // Perhaps it's only the device's built-in default scaling? But that seems pretty
        // useless, and isn't what the docs seem to imply.
        //
        //   var deviceScaleFactor = SCALE_125_PERCENT
        //   _ = GetScaleFactorForMonitor(monitor, &deviceScaleFactor)

        let hwnd = cachedAppWindow.getHWND()!
        let monitor = MonitorFromWindow(hwnd, DWORD(bitPattern: MONITOR_DEFAULTTONEAREST))!

        var x: UINT = 0
        var y: UINT = 0
        let result = GetDpiForMonitor(monitor, MDT_EFFECTIVE_DPI, &x, &y)

        let windowScaleFactor: Double
        if result == S_OK {
            windowScaleFactor = Double(x) / Double(USER_DEFAULT_SCREEN_DPI)
        } else {
            logger.warning("failed to get window scale factor, defaulting to 1.0")
            windowScaleFactor = 1
        }

        return windowScaleFactor
    }

    public override init() {
        grid = WinUI.Grid()

        super.init()

        let menuBarRowDefinition = WinUI.RowDefinition()
        menuBarRowDefinition.height = WinUI.GridLength(
            value: Double(Self.menuBarHeight),
            gridUnitType: .pixel
        )
        let contentRowDefinition = WinUI.RowDefinition()
        grid.rowDefinitions.append(menuBarRowDefinition)
        grid.rowDefinitions.append(contentRowDefinition)
        grid.children.append(menuBar)
        WinUI.Grid.setRow(menuBar, 0)

        self.content = grid

        // Caching appWindow is apparently a good idea in terms of performance:
        // https://github.com/thebrowsercompany/swift-winrt/issues/199#issuecomment-2611006020
        cachedAppWindow = appWindow
    }

    public func setChild(_ child: WinUIBackend.Widget) {
        self.child = child

        grid.children.append(child)
        WinUI.Grid.setRow(child, 1)
    }
}
