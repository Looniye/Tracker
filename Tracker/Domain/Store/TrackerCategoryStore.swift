import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
	func didUpdate()
}

final class TrackerCategoryStore: NSObject {
	
	// MARK: - Properties

	weak var delegate: TrackerCategoryStoreDelegate?
	var categoriesCoreData: [TrackerCategoryCoreData] {
		fetchedResultsController.fetchedObjects ?? []
	}
	
	private let context: NSManagedObjectContext
	private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
		let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(keyPath: \TrackerCategoryCoreData.createdAt, ascending: true)
		]
		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		fetchedResultsController.delegate = self
		try? fetchedResultsController.performFetch()
		return fetchedResultsController
	}()

	// MARK: - Lifecycle
	
	convenience override init() {
			let coreDataStack = CoreDataStack.shared
			let context = coreDataStack.persistentContainer.viewContext
			try! self.init(context: context)
		}
	
	init(context: NSManagedObjectContext) throws {
		self.context = context
		super.init()
	}
	
	// MARK: - Public
	
	func categoryCoreData(with id: UUID) throws -> TrackerCategoryCoreData {
		let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString)
		let category = try context.fetch(request)
		return category[0]
	}
	
	func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
		guard
			let idString = coreData.categoryId,
			let id = UUID(uuidString: idString),
			let label = coreData.label
		else { throw StoreError.decodeError }
		return TrackerCategory(id: id,label: label)
	}
	
	@discardableResult
	func makeCategory(with label: String) throws -> TrackerCategory {
		let category = TrackerCategory(label: label)
		let categoryCoreData = TrackerCategoryCoreData(context: context)
		categoryCoreData.categoryId = category.id.uuidString
		categoryCoreData.createdAt = Date()
		categoryCoreData.label = category.label
		try context.save()
		return category
	}
	
	func updateCategory(with data: TrackerCategory.Data) throws {
		let category = try getCategoryCoreData(by: data.id)
		category.label = data.label
		try context.save()
	}
	
	func deleteCategory(_ category: TrackerCategory) throws {
		let categoryToDelete = try getCategoryCoreData(by: category.id)
		context.delete(categoryToDelete)
		try context.save()
	}
	
	// MARK: - Private
	
	private func getCategoryCoreData(by id: UUID) throws -> TrackerCategoryCoreData {
		fetchedResultsController.fetchRequest.predicate = NSPredicate(
			format: "%K == %@",
			#keyPath(TrackerCategoryCoreData.categoryId), id.uuidString
		)
		try fetchedResultsController.performFetch()
		guard let category = fetchedResultsController.fetchedObjects?.first else { throw StoreError.fetchCategoryError }
		fetchedResultsController.fetchRequest.predicate = nil
		try fetchedResultsController.performFetch()
		return category
	}
}

extension TrackerCategoryStore {
	enum StoreError: Error {
		case decodeError, fetchCategoryError
	}
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didUpdate()
	}
}
