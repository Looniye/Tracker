import Foundation
import CoreData

final class CoreDataStack {
	static let shared = CoreDataStack()
	
	private init() {}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Model")
		container.loadPersistentStores { description, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
}
