import SwiftCrossUI
import WinUI
import UWP

extension WinUIBackend {
    public func createButton(
        wrapping widget: Widget
    ) -> Widget {
        let button = CustomButton()
        button.content = widget
        return button
    }

    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! CustomButton
        button.action = action
        button.buttonStyle = environment.buttonStyle ?? defaultButtonStyle()
        button.enabled = environment.isEnabled
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? defaultButtonStyle() {
            case .bordered: SIMD2(
                    CustomButton.horizontalPadding * 2,
                    CustomButton.verticalPadding * 2,
                )
            case .plain, .borderless: SIMD2(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle { .bordered }
}

fileprivate final class CustomButton: WinUI.Button {
    static let horizontalPadding: Int = 11
    static let verticalPadding: Int = 4

    fileprivate var action: (() -> Void)?

    private var isPointerCaptured = false
    fileprivate var isHighlighted = false {
        didSet {
            buttonStyle.applyModifications(self)
        }
    }

    fileprivate var buttonStyle: ButtonStyle = .bordered {
        didSet {
            if buttonStyle != oldValue {
                updateButtonAppearance()
            }
        }
    }

    // Sadly we can't override isEnabled due to it not being an open property
    public var enabled: Bool = true {
        didSet {
            self.isEnabled = enabled

            if !enabled {
                isPointerCaptured = false
                isHighlighted = false
            }

            buttonStyle.applyModifications(self)
        }
    }

    override init() {
        super.init()
        padding = Thickness.null
        horizontalContentAlignment = HorizontalAlignment.center
        verticalContentAlignment = VerticalAlignment.center

        click.addHandler { [weak self] _, _ in
            guard let self else { return }
            self.action?()
        }
    }

    override func onPointerPressed(_ e: PointerRoutedEventArgs!) throws {
        try super.onPointerPressed(e)
        isPointerCaptured = true
        isHighlighted = true
    }

    override func onPointerMoved(_ e: PointerRoutedEventArgs!) throws {
        try super.onPointerMoved(e)

        if isPointerCaptured {
            // Pointer position relative to the button.
            guard let currentPoint = try e.getCurrentPoint(self) else { return }
            let position = currentPoint.position

            let width = self.actualWidth
            let height = self.actualHeight

            // Apparently windows uses 0 <= x < actualWidth ¯\_(ツ)_/¯
            if
                (0..<width).contains(Double(position.x)),
                (0..<height).contains(Double(position.y))
            {
                isHighlighted = true
            } else {
                isHighlighted = false
            }
        }
    }

    override func onPointerReleased(_ e: PointerRoutedEventArgs!) throws {
        try super.onPointerReleased(e)
        isPointerCaptured = false
        isHighlighted = false
    }

    override func onPointerCaptureLost(_ e: PointerRoutedEventArgs!) throws {
        try super.onPointerCaptureLost(e)
        isPointerCaptured = false
        isHighlighted = false
    }

    override func onKeyDown(_ e: KeyRoutedEventArgs!) throws {
        try super.onKeyDown(e)

        let targetKey = e.key

        if [.space, .enter].contains(targetKey) {
            isHighlighted = true
        }
    }

    override func onKeyUp(_ e: KeyRoutedEventArgs!) throws {
        try super.onKeyUp(e)

        let targetKey = e.key

        if [.space, .enter].contains(targetKey) {
            isHighlighted = false
        }
    }

    override func onLostFocus(_ e: RoutedEventArgs!) throws {
        try super.onLostFocus(e)
        isPointerCaptured = false
        isHighlighted = false
    }

    private func updateButtonAppearance() {
        buttonStyle.applyModifications(self)
        buttonStyle.updateRenderedStyle(self)
    }
}

extension ButtonStyle {
    fileprivate func updateRenderedStyle(_ button: CustomButton) {
        guard let resources = button.resources else { return }

        switch button.buttonStyle {
            case .bordered:
                _ = try? button.clearValue(WinUI.Button.backgroundProperty)
                _ = try? button.clearValue(WinUI.Button.borderBrushProperty)
                _ = try? button.clearValue(WinUI.Button.borderThicknessProperty)
                _ = try? button.clearValue(WinUI.Button.cornerRadiusProperty)

                _ = try? resources.remove("ButtonBackgroundPointerOver")
                _ = try? resources.remove("ButtonBackgroundPressed")
                _ = try? resources.remove("ButtonBackgroundDisabled")

                _ = try? resources.remove("ButtonBorderBrushPointerOver")
                _ = try? resources.remove("ButtonBorderBrushPressed")
                _ = try? resources.remove("ButtonBorderBrushDisabled")
            case .plain, .borderless:
                let transparentBrush = SolidColorBrush(UWP.Color.transparent)
                button.background = transparentBrush
                button.borderBrush = transparentBrush
                button.borderThickness = Thickness.null
                button.cornerRadius = CornerRadius.null

                resources.insert("ButtonBackgroundPointerOver", transparentBrush)
                resources.insert("ButtonBackgroundPressed", transparentBrush)
                resources.insert("ButtonBackgroundDisabled", transparentBrush)

                resources.insert("ButtonBorderBrushPointerOver", transparentBrush)
                resources.insert("ButtonBorderBrushPressed", transparentBrush)
                resources.insert("ButtonBorderBrushDisabled", transparentBrush)
        }
    }

    fileprivate func applyModifications(_ button: CustomButton) {
        switch self {
            case .bordered: button.opacity = 1.0
            case .plain, .borderless:
                button.opacity = button.enabled
                    ? button.isHighlighted ? 0.7: 1.0
                    : 0.36
        }
    }
}

extension UWP.Color {
    static let transparent: Self = Color(a: 0, r: 0, g: 0, b: 0)
}

extension WinUI.Thickness {
    static let null: Self = Thickness(left: 0, top: 0, right: 0, bottom: 0)
}

extension WinUI.CornerRadius {
    static let null: Self = CornerRadius(topLeft: 0, topRight: 0, bottomRight: 0, bottomLeft: 0)
}
