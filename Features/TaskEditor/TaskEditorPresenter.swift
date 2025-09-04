import Foundation

final class TaskEditorPresenter {
    weak var view: TaskEditorViewProtocol?
    var interactor: TaskEditorInteractorProtocol!
    var router: TaskEditorRouterProtocol!
    
    private var mode: TaskEditorMode = .add
    
    func configure(mode: TaskEditorMode) {
        self.mode = mode
    }
}

// MARK: - TaskEditorPresenterProtocol
extension TaskEditorPresenter: TaskEditorPresenterProtocol {
    func viewDidLoad() {
        view?.setupForMode(mode)
    }
    
    func didTapSave(title: String, details: String?) {
        guard !title.isEmpty else {
            view?.showError("Please enter a task title")
            return
        }
        
        view?.showLoading()
        
        switch mode {
        case .add:
            interactor.saveTask(title: title, details: details)
            
        case .edit(let task):
            interactor.updateTask(task, title: title, details: details)
        }
    }
    
    func didTapCancel() {
        router.dismissView()
    }
    
    func didChangeTitleText(_ text: String) {
        let isValid = !text.isEmpty
        view?.showSaveButton(enabled: isValid)
    }
}

// MARK: - TaskEditorInteractorOutputProtocol
extension TaskEditorPresenter: TaskEditorInteractorOutputProtocol {
    func didSaveTask() {
        view?.hideLoading()
        view?.showSuccess("Task created successfully")
    }
    
    func didFailToSaveTask(_ error: Error) {
        view?.hideLoading()
        view?.showError("Failed to save task: \(error.localizedDescription)")
    }
    
    func didUpdateTask() {
        view?.hideLoading()
        view?.showSuccess("Task updated successfully")
    }
    
    func didFailToUpdateTask(_ error: Error) {
        view?.hideLoading()
        view?.showError("Failed to update task: \(error.localizedDescription)")
    }
}
