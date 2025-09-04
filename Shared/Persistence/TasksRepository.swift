import Foundation
import CoreData

protocol TasksRepositoryProtocol {
    func fetchTasks() -> [TaskEntity]
    func createTask(title: String, details: String?) -> TaskEntity
    func updateTask(_ task: TaskEntity, title: String, details: String?, completed: Bool)
    func deleteTask(_ task: TaskEntity)
    func searchTasks(query: String) -> [TaskEntity]
    func seedInitialData() async
    func hasSeededData() -> Bool
}

final class TasksRepository: TasksRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let networkService: NetworkServiceProtocol
    private let userDefaults = UserDefaults.standard
    
    private static let hasSeededKey = "hasSeededInitialData"
    
    init(coreDataStack: CoreDataStack = .shared, 
         networkService: NetworkServiceProtocol = NetworkService()) {
        self.coreDataStack = coreDataStack
        self.networkService = networkService
    }
    
    func fetchTasks() -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try coreDataStack.context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func createTask(title: String, details: String?) -> TaskEntity {
        let context = coreDataStack.context
        let task = TaskEntity(context: context)
        task.id = Int64(Date().timeIntervalSince1970)
        task.todo = title
        task.details = details
        task.createdAt = Date()
        task.completed = false
        task.userId = 0 // Local user
        
        coreDataStack.saveContext()
        return task
    }
    
    func updateTask(_ task: TaskEntity, title: String, details: String?, completed: Bool) {
        task.todo = title
        task.details = details
        task.completed = completed
        coreDataStack.saveContext()
    }
    
    func deleteTask(_ task: TaskEntity) {
        coreDataStack.context.delete(task)
        coreDataStack.saveContext()
    }
    
    func searchTasks(query: String) -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "todo CONTAINS[cd] %@ OR details CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try coreDataStack.context.fetch(request)
        } catch {
            print("Error searching tasks: \(error)")
            return []
        }
    }
    
    func hasSeededData() -> Bool {
        return userDefaults.bool(forKey: Self.hasSeededKey)
    }
    
    func seedInitialData() async {
        guard !hasSeededData() else { return }
        
        let backgroundContext = coreDataStack.backgroundContext
        
        do {
            let todos = try await networkService.fetchTodos()
            
            await backgroundContext.perform {
                for todoResponse in todos {
                    let task = TaskEntity(context: backgroundContext)
                    task.id = Int64(todoResponse.id)
                    task.todo = todoResponse.todo
                    task.details = "" // API doesn't provide details, so we set empty
                    task.createdAt = Date()
                    task.completed = todoResponse.completed
                    task.userId = Int64(todoResponse.userId)
                }
                
                self.coreDataStack.saveBackgroundContext(backgroundContext)
            }
            
            await MainActor.run {
                self.userDefaults.set(true, forKey: Self.hasSeededKey)
            }
            
        } catch {
            print("Error seeding data: \(error)")
        }
    }
}
