import Foundation

final class TasksListInteractor {
    weak var output: TasksListInteractorOutputProtocol?
    private let repository: TasksRepositoryProtocol
    private var observers: [NSObjectProtocol] = []
    
    init(repository: TasksRepositoryProtocol = TasksRepository()) {
        self.repository = repository
        observeStoreChanges()
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func observeStoreChanges() {
        let ctx = CoreDataStack.shared.context
        let didSave = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.fetchTasks()
        }
        observers.append(didSave)

        let didChange = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: ctx,
            queue: .main
        ) { [weak self] _ in
            self?.fetchTasks()
        }
        observers.append(didChange)
    }
}

// MARK: - TasksListInteractorProtocol
extension TasksListInteractor: TasksListInteractorProtocol {
    func fetchTasks() {
        let tasks = repository.fetchTasks()
        output?.didFetchTasks(tasks)
    }
    
    func deleteTask(_ task: TaskEntity) {
        do {
            repository.deleteTask(task)
            output?.didDeleteTask()
        } catch {
            output?.didFailToDeleteTask(error)
        }
    }
    
    func searchTasks(query: String) {
        let tasks = repository.searchTasks(query: query)
        output?.didSearchTasks(tasks)
    }
    
    func toggleTaskCompletion(_ task: TaskEntity) {
        repository.updateTask(
            task,
            title: task.todo ?? "",
            details: task.details,
            completed: !task.completed
        )
        output?.didToggleTaskCompletion()
    }
    
    func seedDataIfNeeded() {
        guard !repository.hasSeededData() else {
            return
        }
        
        Task {
            await repository.seedInitialData()
            await MainActor.run {
                self.output?.didSeedData()
            }
        }
    }
}
