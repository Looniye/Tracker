import UIKit

protocol CategoryFormViewControllerDelegate: AnyObject {
    func didConfirm(_ data: TrackerCategory.Data)
}

final class CategoryFormViewController: UIViewController {
    
    // MARK: - Layout elements
    
    private lazy var textField: UITextField = {
        let textField = TextField(placeholder: "Введите название категории")
        textField.addTarget(self, action: #selector(didChangedTextField), for: .editingChanged)
        return textField
    }()
    private lazy var button: UIButton = {
        let button = Button(title: "Готово")
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.isEnabled = false
        button.backgroundColor = .gray
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: CategoryFormViewControllerDelegate?
    private var data: TrackerCategory.Data
    private var isConfirmButtonEnabled: Bool = false {
        willSet {
            if newValue {
                button.backgroundColor = .black
                button.isEnabled = true
            } else {
                button.backgroundColor = .gray
                button.isEnabled = false
            }
        }
    }
    
    // MARK: - Lifecycle
    
    init(data: TrackerCategory.Data = TrackerCategory.Data()) {
        self.data = data
        
        super.init(nibName: nil, bundle: nil)
        
        textField.text = data.label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        setupContent()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc
    private func didChangedTextField(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            data.label = text
            isConfirmButtonEnabled = true
        } else {
            isConfirmButtonEnabled = false
        }
    }
    
    @objc
    private func didTapButton() {
        delegate?.didConfirm(data)
    }
}

// MARK: - Layout methods

private extension CategoryFormViewController {
    func setupContent() {
        title = "Новая категория"
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(button)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // textField
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: ListItem.height),
            // button
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
