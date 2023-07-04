import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didConfirm(_ schedule: [Weekday])
}

final class ScheduleViewController: UIViewController {
    // MARK: - Layout elements
    
    private let weekdaysTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(WeekdayCell.self, forCellReuseIdentifier: WeekdayCell.identifier)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()
    private lazy var confirmButton: UIButton = {
        let button = Button(title: "Готово")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedWeekdays: Set<Weekday> = []

    // MARK: - Lifecycle
    
    init(selectedWeekdays: [Weekday]) {
        self.selectedWeekdays = Set(selectedWeekdays)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapConfirmButton() {
        let weekdays = Array(selectedWeekdays).sorted()
        delegate?.didConfirm(weekdays)
    }
}

// MARK: - Layout methods

private extension ScheduleViewController {
    func setupContent() {
        title = "Расписание"
        view.backgroundColor = .white
        view.addSubview(weekdaysTableView)
        view.addSubview(confirmButton)
        
        weekdaysTableView.dataSource = self
        weekdaysTableView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // weekdaysTableView
            weekdaysTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            weekdaysTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            weekdaysTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            weekdaysTableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16),
            // confirmButton
            confirmButton.leadingAnchor.constraint(equalTo: weekdaysTableView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: weekdaysTableView.trailingAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let weekdayCell = tableView.dequeueReusableCell(withIdentifier: WeekdayCell.identifier) as? WeekdayCell else { return UITableViewCell() }
        
        let weekday = Weekday.allCases[indexPath.row]
        var position: ListItem.Position
        
        switch indexPath.row {
        case 0:
            position = .first
        case Weekday.allCases.count - 1:
            position = .last
        default:
            position = .middle
        }
        
        weekdayCell.configure(
            with: weekday,
            isSelected: selectedWeekdays.contains(weekday),
            position: position
        )
        weekdayCell.delegate = self
        return weekdayCell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListItem.height
    }
}

// MARK: - WeekdayCellDelegate

extension ScheduleViewController: WeekdayCellDelegate {
    func didToggleSwitchView(to isSelected: Bool, of weekday: Weekday) {
        if isSelected {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}
