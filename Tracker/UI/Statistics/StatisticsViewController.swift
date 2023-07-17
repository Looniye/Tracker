import UIKit

final class StatisticsViewController: UIViewController {
	
	// MARK: - Layout elements
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = L10n.Statistics.title
		label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
		return label
	}()
	
	private let notFoundStack = NotFoundStack(
		label: "Анализировать пока нечего",
		image: UIImage(named: "Sad")
	)
	
	private let statisticsStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		return stack
	}()
	
	private let completedTrackersView = StatisticsView(name: "Трекеров завершено")
	
	// MARK: - Properties
	
	var statisticsViewModel: StatisticsViewModel?
	private let trackerRecordStore = TrackerRecordStore()

	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupContent()
		setupConstraints()
		
		statisticsViewModel?.onTrackersChange = { [weak self] trackers in
			guard let self else { return }
			self.checkContent(with: trackers)
			self.setupCompletedTrackersBlock(with: trackers.count)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		statisticsViewModel?.viewWillAppear()
	}
	
	// MARK: - Private
	
	private func checkContent(with trackers: [TrackerRecord]) {
		if trackers.isEmpty {
			notFoundStack.isHidden = false
			statisticsStack.isHidden = true
		} else {
			notFoundStack.isHidden = true
			statisticsStack.isHidden = false
		}
	}
	
	private func setupCompletedTrackersBlock(with count: Int) {
		completedTrackersView.setNumber(count)
	}

}

// MARK: - Layout methods

private extension StatisticsViewController {
	
	func setupContent() {
		view.backgroundColor = .white
		view.addSubview(titleLabel)
		view.addSubview(notFoundStack)
		view.addSubview(statisticsStack)
		statisticsStack.addArrangedSubview(completedTrackersView)
	}
	
	func setupConstraints() {
		NSLayoutConstraint.activate([
			// titleLabel
			titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
			// notFoundStack
			notFoundStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			notFoundStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			// statisticsStack
			statisticsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			statisticsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			statisticsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
		])
	}
	
}
