import Foundation

final class TasksListPresenter {
    weak var view: TasksListViewProtocol?
    var interactor: TasksListInteractorProtocol!
    var router: TasksListRouterProtocol!
}

// MARK: - TasksListPresenterProtocol
extension TasksListPresenter: TasksListPresenterProtocol {
    func viewDidLoad() {
        view?.showLoading()
        interactor.seedDataIfNeeded()
        interactor.fetchTasks()
    }
    
    func didTapAddTask() {
        router.navigateToAddTask()
    }
    
    func didTapEditTask(_ task: TaskEntity) {
        router.navigateToEditTask(task)
    }
    
    func didTapDeleteTask(_ task: TaskEntity) {
        interactor.deleteTask(task)
    }
    
    func didSearchTasks(query: String) {
        interactor.searchTasks(query: query)
    }
    
    func didClearSearch() {
        interactor.fetchTasks()
    }
    
    func didToggleTaskCompletion(_ task: TaskEntity) {
        interactor.toggleTaskCompletion(task)
    }
}

// MARK: - TasksListInteractorOutputProtocol
extension TasksListPresenter: TasksListInteractorOutputProtocol {
    func didFetchTasks(_ tasks: [TaskEntity]) {
        view?.hideLoading()
        view?.showTasks(tasks)
    }
    
    func didFailToFetchTasks(_ error: Error) {
        view?.hideLoading()
        view?.showError("Failed to fetch tasks: \(error.localizedDescription)")
    }
    
    func didDeleteTask() {
        interactor.fetchTasks() // Refresh the list
    }
    
    func didFailToDeleteTask(_ error: Error) {
        view?.showError("Failed to delete task: \(error.localizedDescription)")
    }
    
    func didSearchTasks(_ tasks: [TaskEntity]) {
        view?.showSearchResults(tasks)
    }
    
    func didToggleTaskCompletion() {
        interactor.fetchTasks() // Refresh the list
    }
    
    func didSeedData() {
        interactor.fetchTasks() // Fetch tasks after seeding
    }
}
