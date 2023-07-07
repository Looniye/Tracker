import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didConfirm(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController {
    
    // MARK: - Layout elements
    
    private let categoriesTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.allowsMultipleSelection = false
        table.backgroundColor = .clear
        return table
    }()
    private let notFoundStack = NotFoundStack(label: "Привычки и события можно объединить по смыслу")
    private lazy var addButton: UIButton = {
        let button = Button(title: "Добавить категорию")
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: CategoriesViewControllerDelegate?
    private let viewModel: CategoriesViewModel
    
    // MARK: - Lifecycle
    
    init(selectedCategory: TrackerCategory?) {
        viewModel = CategoriesViewModel(selectedCategory: selectedCategory)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
        
        viewModel.delegate = self
        viewModel.loadCategories()
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapAddButton() {
        let addCategoryViewController = CategoryFormViewController()
        addCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: - Private
    
    private func editCategory(_ category: TrackerCategory) {
        let addCategoryViewController = CategoryFormViewController(data: category.data)
        addCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true)
    }
    
    private func deleteCategory(_ category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(category)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Layout methods

private extension CategoriesViewController {
    func setupContent() {
        title = "Категория"
        view.backgroundColor = .white
        view.addSubview(categoriesTableView)
        view.addSubview(addButton)
        view.addSubview(notFoundStack)
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // categoriesTableView
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            // addButton
            addButton.leadingAnchor.constraint(equalTo: categoriesTableView.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: categoriesTableView.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            // notFoundStack
            notFoundStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            notFoundStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            notFoundStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let categoryCell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier) as? CategoryCell else { return UITableViewCell() }
        
        let category = viewModel.categories[indexPath.row]
        let isSelected = viewModel.selectedCategory == category
        var position: ListItem.Position
        
        switch indexPath.row {
        case 0:
            position = viewModel.categories.count == 1 ? .alone : .first
        case viewModel.categories.count - 1:
            position = .last
        default:
            position = .middle
        }
        
        categoryCell.configure(with: category.label, isSelected: isSelected, position: position)
        return categoryCell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListItem.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }
}

// MARK: - CategoriesViewModelDelegate

extension CategoriesViewController: CategoriesViewModelDelegate {
    func didUpdateCategories() {
        if viewModel.categories.isEmpty {
            notFoundStack.isHidden = false
        } else {
            notFoundStack.isHidden = true
        }
        categoriesTableView.reloadData()
    }
    
    func didSelectCategory(_ category: TrackerCategory) {
        delegate?.didConfirm(category)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.editCategory(category)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.deleteCategory(category)
                }
            ])
        })
    }
}

extension CategoriesViewController: CategoryFormViewControllerDelegate {
    func didConfirm(_ data: TrackerCategory.Data) {
        viewModel.handleCategoryFormConfirm(data: data)
        dismiss(animated: true)
    }
}
