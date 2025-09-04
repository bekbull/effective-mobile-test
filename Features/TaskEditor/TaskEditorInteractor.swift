import Foundation

final class TaskEditorInteractor {
    weak var output: TaskEditorInteractorOutputProtocol?
    private let repository: TasksRepositoryProtocol
    
    init(repository: TasksRepositoryProtocol = TasksRepository()) {
        self.repository = repository
    }
}

// MARK: - TaskEditorInteractorProtocol
extension TaskEditorInteractor: TaskEditorInteractorProtocol {
    func saveTask(title: String, details: String?) {
        do {
            _ = repository.createTask(title: title, details: details)
            output?.didSaveTask()
        } catch {
            output?.didFailToSaveTask(error)
        }
    }
    
    func updateTask(_ task: TaskEntity, title: String, details: String?) {
        do {
            repository.updateTask(task, title: title, details: details, completed: task.completed)
            output?.didUpdateTask()
        } catch {
            output?.didFailToUpdateTask(error)
        }
    }
}
