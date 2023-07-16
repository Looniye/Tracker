import UIKit

final class NotFoundStack: UIStackView {
	private let notFoundImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let notFoundLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		label.textColor = .black
		return label
	}()
	
	convenience init(label: String, image: UIImage?) {
		self.init()
		
		notFoundLabel.text = label
		notFoundImageView.image = image
		
		setup()
		addSubviews()
	}
	
	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.axis = .vertical
		self.alignment = .center
		self.spacing = 8
	}
	
	private func addSubviews() {
		addArrangedSubview(notFoundImageView)
		addArrangedSubview(notFoundLabel)
	}
}
