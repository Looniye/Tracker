import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func didSelectTracker(with: AddTrackerViewController.TrackerType)
}

final class AddTrackerViewController: UIViewController {
    // MARK: - Layout elements
    
    private lazy var addHabitButton: UIButton = {
        let button = Button(title: "Привычка")
        button.addTarget(self, action: #selector(didTapAddHabitButton), for: .touchUpInside)
        return button
    }()
    private lazy var addIrregularEventButton: UIButton = {
        let button = Button(title: "Нерегулярное событие")
        button.addTarget(self, action: #selector(didTapAddIrregularEventButton), for: .touchUpInside)
        return button
    }()
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Properties
    
    weak var delegate: AddTrackerViewControllerDelegate?
    
    private var labelText = ""
    private var category: String?
    private var schedule: [Weekday]?
    private var emoji: String?
    private var color: UIColor?
    
    private var isConfirmButtonEnabled: Bool {
        labelText.count > 0 && !isValidationMessageVisible
    }
    
    private var isValidationMessageVisible = false
    private var parameters = ["Категория", "Расписание"]
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    private let colors = UIColor.selection

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapAddHabitButton() {
        title = "Новая привычка"
        delegate?.didSelectTracker(with: .habit)
    }
    
    @objc
    private func didTapAddIrregularEventButton() {
        delegate?.didSelectTracker(with: .irregularEvent)
    }
}

// MARK: - Layout methods

private extension AddTrackerViewController {
    func setupContent() {
        title = "Создание трекера"
        view.backgroundColor = .white
        
        view.addSubview(buttonsStack)
        
        buttonsStack.addArrangedSubview(addHabitButton)
        buttonsStack.addArrangedSubview(addIrregularEventButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // buttonsStack
            buttonsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            // addHabitButton
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            // addIrregularEventButton
            addIrregularEventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension AddTrackerViewController {
    enum TrackerType {
        case habit, irregularEvent
    }
}
