import UIKit

final class CategoryCell: UITableViewCell {
    
    // MARK: - Layout elements
    
    private lazy var listItem = ListItem()
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        return imageView
    }()
    
    // MARK: - Properties
    
    static let identifier = "WeekdayCell"
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func configure(with label: String, isSelected: Bool, position: ListItem.Position) {
        listItem.configure(with: position)
        self.label.text = label
        checkmarkImage.isHidden = !isSelected
    }
}

// MARK: - Layout methods

private extension CategoryCell {
    func setupContent() {
        selectionStyle = .none
        contentView.addSubview(listItem)
        contentView.addSubview(label)
        contentView.addSubview(checkmarkImage)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // listItem
            listItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listItem.topAnchor.constraint(equalTo: contentView.topAnchor),
            listItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // label
            label.leadingAnchor.constraint(equalTo: listItem.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: listItem.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -83),
            // checkmarkImage
            checkmarkImage.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            checkmarkImage.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -16)
        ])
    }
}
