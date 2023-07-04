import UIKit

final class TextField: UITextField {
    private let textPadding = UIEdgeInsets(
        top: 0,
        left: 16,
        bottom: 0,
        right: 41
    )
    
    convenience init(placeholder: String) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .background
        self.placeholder = placeholder
        clearButtonMode = .whileEditing
        layer.cornerRadius = 16
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
