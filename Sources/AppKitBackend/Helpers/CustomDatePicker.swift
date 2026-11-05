import AppKit

final class CustomDatePicker: NSDatePicker {
    var strongDelegate = CustomDatePickerDelegate()
    
    override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        if datePickerStyle == .textFieldAndStepper {
            if #available(macOS 27, *) {}
            else if #available(macOS 26, *), LiquidGlassAvailability.isAvailable {
                return NSSize(width: size.width + 4, height: size.height)
            }
        }
        return size
    }
}

final class CustomDatePickerDelegate: NSObject, NSDatePickerCellDelegate {
    var onChange: ((Date) -> Void)?

    func datePickerCell(
        _: NSDatePickerCell,
        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
        timeInterval _: UnsafeMutablePointer<TimeInterval>?
    ) {
        onChange?(proposedDateValue.pointee as Date)
    }
}
