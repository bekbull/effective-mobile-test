import Foundation

final class TaskEditorPresenter {
    weak var view: TaskEditorViewProtocol?
    var interactor: TaskEditorInteractorProtocol!
    var router: TaskEditorRouterProtocol!
    
    private var mode: TaskEditorMode = .add
    private var currentTask: TaskEntity?
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.4
    
    func configure(mode: TaskEditorMode) {
        self.mode = mode
    }
}

// MARK: - TaskEditorPresenterProtocol
extension TaskEditorPresenter: TaskEditorPresenterProtocol {
    func viewDidLoad() {
        view?.setupForMode(mode)
    }
    
    func didTapBack() {
        router.popView()
    }
    
    func didChange(title: String, details: String) {
        let titleTrim = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let detailsTrim = details.trimmingCharacters(in: .whitespacesAndNewlines)
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            switch self.mode {
            case .add:
                if self.currentTask == nil {
                    // Create draft only if there is meaningful input
                    guard !titleTrim.isEmpty || !detailsTrim.isEmpty else { return }
                    self.currentTask = self.interactor.createDraftIfNeeded(title: titleTrim.isEmpty ? "" : titleTrim, details: detailsTrim.isEmpty ? nil : detailsTrim)
                }
                if let task = self.currentTask {
                    self.interactor.updateTask(task, title: titleTrim, details: detailsTrim.isEmpty ? nil : detailsTrim)
                }
            case .edit(let task):
                self.interactor.updateTask(task, title: titleTrim, details: detailsTrim.isEmpty ? nil : detailsTrim)
            }
        }
        debounceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }
    
    func willDisappear() {
        debounceWorkItem?.perform()
        debounceWorkItem = nil
        if case .add = mode, let task = currentTask {
            // If both fields ended up empty, remove draft
            if (task.todo ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (task.details ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                interactor.deleteTask(task)
            }
        }
    }
}

// MARK: - TaskEditorInteractorOutputProtocol
extension TaskEditorPresenter: TaskEditorInteractorOutputProtocol {
    func didSaveTask() {
        view?.hideLoading()
    }
    
    func didFailToSaveTask(_ error: Error) {
        view?.hideLoading()
        view?.showError("Failed to save task: \(error.localizedDescription)")
    }
    
    func didUpdateTask() {
        view?.hideLoading()
    }
    
    func didFailToUpdateTask(_ error: Error) {
        view?.hideLoading()
        view?.showError("Failed to update task: \(error.localizedDescription)")
    }
}
