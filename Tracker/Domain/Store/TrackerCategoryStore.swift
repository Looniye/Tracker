import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Properties

    var categories = [TrackerCategory]()
    
    private let context: NSManagedObjectContext

    // MARK: - Lifecycle
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        try setupCategories(with: context)
    }
    
    // MARK: - Methods
    
    func categoryCoreData(with id: UUID) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString)
        let category = try context.fetch(request)
        return category[0]
    }
    
    private func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard
            let idString = coreData.categoryId,
            let id = UUID(uuidString: idString),
            let label = coreData.label
        else { throw StoreError.decodeError }
        return TrackerCategory(id: id,label: label)
    }
    
    private func setupCategories(with context: NSManagedObjectContext) throws {
        let checkRequest = TrackerCategoryCoreData.fetchRequest()
        let result = try context.fetch(checkRequest)
        
        guard result.count == 0 else {
            categories = try result.map({ try makeCategory(from: $0) })
            return
        }
        
        let _ = [
            TrackerCategory(label: "Домашний уют"),
            TrackerCategory(label: "Радостные мелочи")
        ].map { category in
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.categoryId = category.id.uuidString
            categoryCoreData.createdAt = Date()
            categoryCoreData.label = category.label
            return categoryCoreData
        }
        
        try context.save()
    }
}

extension TrackerCategoryStore {
    enum StoreError: Error {
        case decodeError
    }
}
