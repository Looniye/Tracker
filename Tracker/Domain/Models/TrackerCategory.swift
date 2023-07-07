import UIKit

struct TrackerCategory: Equatable {
	let id: UUID
	let label: String
	
	init(id: UUID = UUID(), label: String) {
		self.id = id
		self.label = label
	}
	
	var data: Data {
		Data(id: id, label: label)
	}
}

extension TrackerCategory {
	struct Data {
		let id: UUID
		var label: String
		
		init(id: UUID? = nil, label: String = "") {
			self.id = id ?? UUID()
			self.label = label
		}
	}
}
