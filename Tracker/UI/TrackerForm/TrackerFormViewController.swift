import UIKit

protocol TrackerFormViewControllerDelegate: AnyObject {
	func didTapCancelButton()
	func didAddTracker(category: TrackerCategory, trackerToAdd: Tracker)
	func didUpdateTracker(with data: Tracker.Data)
}

final class TrackerFormViewController: UIViewController {
	// MARK: - Layout elements
	
	private let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.translatesAutoresizingMaskIntoConstraints = false
		return scroll
	}()
	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	private lazy var textField: UITextField = {
		let textField = TextField(placeholder: "Введите название трекера")
		textField.addTarget(self, action: #selector(didChangedLabelTextField), for: .editingChanged)
		return textField
	}()
	private let validationMessage: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 17)
		label.textColor = .red
		label.text = "Ограничение \(Constants.labelLimit) символов"
		return label
	}()
	private let parametersTableView: UITableView = {
		let table = UITableView()
		table.translatesAutoresizingMaskIntoConstraints = false
		table.separatorStyle = .none
		table.isScrollEnabled = false
		table.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
		return table
	}()
	private let emojisCollection: UICollectionView = {
		let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collection.translatesAutoresizingMaskIntoConstraints = false
		collection.isScrollEnabled = false
		collection.allowsMultipleSelection = false
		collection.register(
			SelectionTitle.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: SelectionTitle.identifier
		)
		collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
		return collection
	}()
	private let colorsCollection: UICollectionView = {
		let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collection.translatesAutoresizingMaskIntoConstraints = false
		collection.isScrollEnabled = false
		collection.allowsMultipleSelection = false
		collection.register(
			SelectionTitle.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: SelectionTitle.identifier
		)
		collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
		return collection
	}()
	private lazy var cancelButton: UIButton = {
		let button = Button.danger(title: "Отменить")
		button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
		return button
	}()
	private lazy var confirmButton: UIButton = {
		let button = Button(title: "Создать")
		button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
		button.isEnabled = false
		return button
	}()
	private let buttonsStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.spacing = 8
		stack.distribution = .fillEqually
		return stack
	}()
	
	// MARK: - Properties
	
	weak var delegate: TrackerFormViewControllerDelegate?
	private let formType: FormType
	private let trackerType: AddTrackerViewController.TrackerType
	private let trackerCategoryStore = TrackerCategoryStore()
	
	private var data: Tracker.Data {
		didSet {
			checkFormValidation()
		}
	}

	private var scheduleString: String? {
		guard let schedule = data.schedule else { return nil }
		if schedule.count == Weekday.allCases.count { return "Каждый день" }
		let shortForms: [String] = schedule.map { $0.shortForm }
		return shortForms.joined(separator: ", ")
	}
	
	private var isConfirmButtonEnabled: Bool = false {
		willSet {
			if newValue {
				confirmButton.backgroundColor = .black
				confirmButton.isEnabled = true
			} else {
				confirmButton.backgroundColor = .gray
				confirmButton.isEnabled = false
			}
		}
	}
	
	private var isValidationMessageVisible = false {
		didSet {
			checkFormValidation()
			if isValidationMessageVisible {
				validationMessageHeightConstraint?.constant = 22
				parametersTableViewTopConstraint?.constant = 32
			} else {
				validationMessageHeightConstraint?.constant = 0
				parametersTableViewTopConstraint?.constant = 16
			}
		}
	}
	private var validationMessageHeightConstraint: NSLayoutConstraint?
	private var parametersTableViewTopConstraint: NSLayoutConstraint?
	private let parameters = ["Категория", "Расписание"]
	private let emojis = [
		"🙂", "😻", "🌺", "🐶", "❤️", "😱",
		"😇", "😡", "🥶", "🤔", "🙌", "🍔",
		"🥦", "🏓", "🥇", "🎸", "🏝", "😪",
	]
	private let colors = UIColor.selection
	private let params = UICollectionView.GeometricParams(
		cellCount: 6,
		leftInset: 28,
		rightInset: 28,
		topInset: 24,
		bottomInset: 24,
		height: 52,
		cellSpacing: 5
	)
	
	// MARK: - Lifecycle
	
	init(
		formType: TrackerFormViewController.FormType,
		trackerType: AddTrackerViewController.TrackerType,
		data: Tracker.Data?
	) {
		self.formType = formType
		self.trackerType = trackerType
		self.data = data ?? Tracker.Data()
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var collectionViewHeightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		hideKeyboardWhenTappedAround()
		
		setFormFields()
		
		setupContent()
		setupConstraints()
		
		checkFormValidation()
	}
	
	// MARK: - Actions
	
	@objc
	private func didChangedLabelTextField(_ sender: UITextField) {
		guard let text = sender.text else { return }
		data.label = text
		if text.count > Constants.labelLimit {
			isValidationMessageVisible = true
		} else {
			isValidationMessageVisible = false
		}
	}
	
	@objc
	private func didTapCancelButton() {
		delegate?.didTapCancelButton()
	}
	
	@objc
	private func didTapConfirmButton() {
		switch formType {
		case .add: addTracker()
		case .edit: editTracker()
		}
	}
	
	// MARK: - Private
	
	private func setFormFields() {
		textField.text = data.label
		switch trackerType {
		case .habit:
			self.data.schedule = data.schedule ?? []
		case .irregularEvent:
			self.data.schedule = nil
		}
	}
	
	private func checkFormValidation() {
		if data.label.count == 0 {
			isConfirmButtonEnabled = false
			return
		}
		
		if isValidationMessageVisible {
			isConfirmButtonEnabled = false
			return
		}
		
		if data.category == nil || data.emoji == nil || data.color == nil {
			isConfirmButtonEnabled = false
			return
		}
		
		if let schedule = data.schedule, schedule.isEmpty {
			isConfirmButtonEnabled = false
			return
		}
		
		isConfirmButtonEnabled = true
	}
	
	private func editTracker() {
		delegate?.didUpdateTracker(with: data)
	}
	
	private func addTracker() {
		guard
			let emoji = data.emoji,
			let color = data.color,
			let category = data.category
		else { return }
		
		let newTracker = Tracker(
			label: data.label,
			emoji: emoji,
			color: color,
			category: category,
			completedDaysCount: 0,
			schedule: data.schedule,
			isPinned: false
		)
		
		delegate?.didAddTracker(category: category, trackerToAdd: newTracker)
	}
}

// MARK: - Layout methods

private extension TrackerFormViewController {
	func setupContent() {
		switch formType {
		case .add:
			switch trackerType {
			case .habit: title = "Новая привычка"
			case .irregularEvent: title = "Новое нерегулярное событие"
			}
		case .edit: title = "Редактирование привычки"
		}
		
		textField.delegate = self
		
		parametersTableView.dataSource = self
		parametersTableView.delegate = self
		
		emojisCollection.dataSource = self
		emojisCollection.delegate = self
		
		colorsCollection.dataSource = self
		colorsCollection.delegate = self
		
		view.backgroundColor = .white
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(textField)
		contentView.addSubview(validationMessage)
		contentView.addSubview(parametersTableView)
		contentView.addSubview(emojisCollection)
		contentView.addSubview(colorsCollection)
		contentView.addSubview(buttonsStack)
		
		buttonsStack.addArrangedSubview(cancelButton)
		buttonsStack.addArrangedSubview(confirmButton)
	}
	
	func setupConstraints() {
		validationMessageHeightConstraint = validationMessage.heightAnchor.constraint(equalToConstant: 0)
		parametersTableViewTopConstraint = parametersTableView.topAnchor.constraint(equalTo: validationMessage.bottomAnchor, constant: 16)
		validationMessageHeightConstraint?.isActive = true
		parametersTableViewTopConstraint?.isActive = true
		
		NSLayoutConstraint.activate([
			// scrollView
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			// contentView
			contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
			// textField
			textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
			textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			textField.heightAnchor.constraint(equalToConstant: ListItem.height),
			// validationMessage
			validationMessage.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
			validationMessage.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
			// parametersTableView
			parametersTableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
			parametersTableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
			parametersTableView.heightAnchor.constraint(equalToConstant: data.schedule == nil ? ListItem.height : 2 *  ListItem.height),
			// emojiCollection
			emojisCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			emojisCollection.topAnchor.constraint(equalTo: parametersTableView.bottomAnchor, constant: 32),
			emojisCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			emojisCollection.heightAnchor.constraint(
				equalToConstant: CGFloat(emojis.count) / params.cellCount * params.height + 18 + params.topInset + params.bottomInset
			),
			// colorsCollection
			colorsCollection.leadingAnchor.constraint(equalTo: emojisCollection.leadingAnchor),
			colorsCollection.topAnchor.constraint(equalTo: emojisCollection.bottomAnchor, constant: 16),
			colorsCollection.trailingAnchor.constraint(equalTo: emojisCollection.trailingAnchor),
			colorsCollection.heightAnchor.constraint(
				equalToConstant: CGFloat(colors.count) / params.cellCount * params.height + 18 + params.topInset + params.bottomInset
			),
			// buttonsStack
			buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
			buttonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			buttonsStack.heightAnchor.constraint(equalToConstant: 60),
		])
	}
}

extension TrackerFormViewController {
	enum FormType {
		case add, edit
	}
}

// MARK: - UITextFieldDelegate

extension TrackerFormViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - UITableViewDataSource

extension TrackerFormViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if data.schedule == nil {
			return 1
		}
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let listCell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier) as? ListCell
		else { return UITableViewCell() }

		var position: ListItem.Position
		var value: String? = nil

		if data.schedule == nil {
			position = .alone
			value = data.category?.label
		} else {
			position = indexPath.row == 0 ? .first : .last
			value = indexPath.row == 0 ? data.category?.label : scheduleString
		}

		listCell.configure(label: parameters[indexPath.row], value: value, position: position)
		return listCell
	}
}

// MARK: - UITableViewDelegate

extension TrackerFormViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			let categoriesViewController = CategoriesViewController(selectedCategory: data.category)
			categoriesViewController.delegate = self
			let navigationController = UINavigationController(rootViewController: categoriesViewController)
			navigationController.isModalInPresentation = true
			present(navigationController, animated: true)
		case 1:
			guard let schedule = data.schedule else { return }
			let scheduleViewController = ScheduleViewController(selectedWeekdays: schedule)
			scheduleViewController.delegate = self
			let navigationController = UINavigationController(rootViewController: scheduleViewController)
			present(navigationController, animated: true)
		default:
			return
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		ListItem.height
	}
}

// MARK: - CategoriesViewControllerDelegate

extension TrackerFormViewController: CategoriesViewControllerDelegate {
	func didConfirm(_ category: TrackerCategory) {
		data.category = category
		parametersTableView.reloadData()
		dismiss(animated: true)
	}
}

// MARK: - ScheduleViewControllerDelegate

extension TrackerFormViewController: ScheduleViewControllerDelegate {
	func didConfirm(_ schedule: [Weekday]) {
		data.schedule = schedule
		parametersTableView.reloadData()
		dismiss(animated: true)
	}
}

// MARK: - UICollectionViewDataSource

extension TrackerFormViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionView {
		case emojisCollection: return emojis.count
		case colorsCollection: return colors.count
		default: return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch collectionView {
		case emojisCollection:
			guard let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
			let emoji = emojis[indexPath.row]
			emojiCell.configure(with: emoji)
			if emoji == data.emoji {
				emojiCell.select()
				emojisCollection.selectItem(
					at: indexPath,
					animated: false,
					scrollPosition: .bottom
				)
			}
			return emojiCell
		case colorsCollection:
			guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
			let color = colors[indexPath.row]
			colorCell.configure(with: color)
			if
				let dataColor = data.color,
				UIColorMarshalling.makeHEX(from: color) == UIColorMarshalling.makeHEX(from: dataColor)
			{
				colorCell.select()
				colorsCollection.selectItem(
					at: indexPath,
					animated: false,
					scrollPosition: .bottom
				)
			}
			return colorCell
		default:
			return UICollectionViewCell()
		}
	}
}

// MARK: - UICollectionViewDelegate

extension TrackerFormViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) as? SelectionCellProtocol else { return }
		switch collectionView {
		case emojisCollection: data.emoji = emojis[indexPath.row]
		case colorsCollection: data.color = colors[indexPath.row]
		default: break
		}
		cell.select()
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) as? SelectionCellProtocol else { return }
		cell.deselect()
	}
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerFormViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		let availableSpace = collectionView.frame.width - params.paddingWidth
		let cellWidth = availableSpace / params.cellCount
		return CGSize(width: cellWidth, height: params.height)
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		insetForSectionAt section: Int) -> UIEdgeInsets
	{
		UIEdgeInsets(
			top: params.topInset,
			left: params.leftInset,
			bottom: params.bottomInset,
			right: params.rightInset
		)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		params.cellSpacing
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int) -> CGFloat
	{
		0
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath) -> UICollectionReusableView
	{
		guard
			kind == UICollectionView.elementKindSectionHeader,
			let view = collectionView.dequeueReusableSupplementaryView(
				ofKind: UICollectionView.elementKindSectionHeader,
				withReuseIdentifier: SelectionTitle.identifier,
				for: indexPath
			) as? SelectionTitle
		else { return UICollectionReusableView() }
		
		var label: String
		switch collectionView {
		case emojisCollection: label = "Emoji"
		case colorsCollection: label = "Цвет"
		default: label = ""
		}
		
		view.configure(with: label)
		
		return view
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		referenceSizeForHeaderInSection section: Int) -> CGSize
	{
		let indexPath = IndexPath(row: 0, section: section)
		let headerView = self.collectionView(
			collectionView,
			viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
			at: indexPath
		)
		
		return headerView.systemLayoutSizeFitting(
			CGSize(
				width: collectionView.frame.width,
				height: UIView.layoutFittingExpandedSize.height
			),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		)
	}
}
