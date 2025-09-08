import Foundation

final class TaskEditorInteractor {
    weak var output: TaskEditorInteractorOutputProtocol?
    private let repository: TasksRepositoryProtocol
    private var draftTask: TaskEntity?
    
    init(repository: TasksRepositoryProtocol = TasksRepository()) {
        self.repository = repository
    }
}

// MARK: - TaskEditorInteractorProtocol
extension TaskEditorInteractor: TaskEditorInteractorProtocol {
    func createDraftIfNeeded(title: String, details: String?) -> TaskEntity {
        if let existing = draftTask { return existing }
        let created = repository.createTask(title: title, details: details)
        draftTask = created
        return created
    }
    
    func updateTask(_ task: TaskEntity, title: String, details: String?) {
        repository.updateTask(task, title: title, details: details, completed: task.completed)
        output?.didUpdateTask()
    }
    
    func deleteTask(_ task: TaskEntity) {
        repository.deleteTask(task)
    }
}
