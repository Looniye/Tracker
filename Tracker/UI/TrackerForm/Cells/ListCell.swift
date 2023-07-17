import UIKit

final class ListCell: UITableViewCell {
    // MARK: - Layout elements
    
    private lazy var listItem = ListItem()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 2
        stack.axis = .vertical
        return stack
    }()
    private let chooseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    // MARK: - Properties
    
    static let identifier = "ListCell"
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(label: String, value: String?, position: ListItem.Position) {
        listItem.configure(with: position)
        nameLabel.text = label
        
        if let value {
            valueLabel.text = value
        }
    }
}

// MARK: - Layout methods

private extension ListCell {
    func setupContent() {
        selectionStyle = .none
        contentView.addSubview(listItem)
        contentView.addSubview(labelsStack)
        labelsStack.addArrangedSubview(nameLabel)
        labelsStack.addArrangedSubview(valueLabel)
        contentView.addSubview(chooseButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // listItem
            listItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listItem.topAnchor.constraint(equalTo: contentView.topAnchor),
            listItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // labelsStack
            labelsStack.leadingAnchor.constraint(equalTo: listItem.leadingAnchor, constant: 16),
            labelsStack.centerYAnchor.constraint(equalTo: listItem.centerYAnchor),
            labelsStack.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -56),
            // chooseButton
            chooseButton.centerYAnchor.constraint(equalTo: listItem.centerYAnchor),
            chooseButton.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -24),
            chooseButton.widthAnchor.constraint(equalToConstant: 8),
            chooseButton.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
}
