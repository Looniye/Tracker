import UIKit

final class OnboardingPageViewController: UIViewController {
	
	// MARK: - Layout elements
	
	private let label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.boldSystemFont(ofSize: 32)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.textColor = .white
		return label
	}()
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	// MARK: - Properties
	
	private let text: String
	private let backgroundImage: UIImage
	
	// MARK: - Lifecycle
	
	init(text: String, backgroundImage: UIImage) {
		self.text = text
		self.backgroundImage = backgroundImage
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
}

// MARK: - Layout methods

private extension OnboardingPageViewController {
	func setupContent() {
		imageView.image = backgroundImage
		label.text = text
		
		view.addSubview(imageView)
		view.addSubview(label)
	}
	
	func setupConstraints() {
		NSLayoutConstraint.activate([
			// imageView
			imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			imageView.topAnchor.constraint(equalTo: view.topAnchor),
			imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			// label
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			label.topAnchor.constraint(equalTo: view.centerYAnchor),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
	}
}
