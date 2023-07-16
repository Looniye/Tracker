import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - Layout elements
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    // MARK: - Properties
    
    static let identifier = "EmojiCell"
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(with label: String) {
        emojiLabel.text = label
    }
}

// MARK: - Layout methods

private extension EmojiCell {
    func setupContent() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(emojiLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // emojiLabel
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

// MARK: - SelectionCellProtocol

extension EmojiCell: SelectionCellProtocol {
    func select() {
        contentView.backgroundColor = .lightGray
    }
    
    func deselect() {
        contentView.backgroundColor = .clear
    }
}
