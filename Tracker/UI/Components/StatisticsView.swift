import UIKit

final class StatisticsView: UIView {
    
    // MARK: - Layout elements
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - Properties
    
    private var number: Int {
        didSet {
            numberLabel.text = "\(number)"
        }
    }
    private var name: String {
        didSet {
            nameLabel.text = name
        }
    }
    
    // MARK: - Lifecycle
    
    required init(number: Int = 0, name: String) {
        self.number = number
        self.name = name
        
        super.init(frame: .zero)
        setNumber(number)
        setName(name)
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBorder()
    }
    
    // MARK: - Public
    
    func setNumber(_ number: Int) {
        self.number = number
    }
    
    func setName(_ name: String) {
        self.name = name
    }
}

// MARK: - Layout methods

private extension StatisticsView {
    
    func setupContent() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(numberLabel)
        addSubview(nameLabel)
    }
    
    func setupBorder() {
        gradientBorder(
            width: 1,
            colors: UIColor.gradient,
            startPoint: .unitCoordinate(.left),
            endPoint: .unitCoordinate(.right),
            andRoundCornersWithRadius: 12
        )
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // numberLabel
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            // nameLabel
            nameLabel.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: numberLabel.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
}
