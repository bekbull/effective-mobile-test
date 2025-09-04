import Foundation
import UIKit

// MARK: - View Protocol
protocol TasksListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskEntity])
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showSearchResults(_ tasks: [TaskEntity])
}

// MARK: - Presenter Protocol
protocol TasksListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAddTask()
    func didTapEditTask(_ task: TaskEntity)
    func didTapDeleteTask(_ task: TaskEntity)
    func didSearchTasks(query: String)
    func didClearSearch()
    func didToggleTaskCompletion(_ task: TaskEntity)
}

// MARK: - Interactor Protocol
protocol TasksListInteractorProtocol: AnyObject {
    func fetchTasks()
    func deleteTask(_ task: TaskEntity)
    func searchTasks(query: String)
    func toggleTaskCompletion(_ task: TaskEntity)
    func seedDataIfNeeded()
}

// MARK: - Router Protocol
protocol TasksListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func navigateToAddTask()
    func navigateToEditTask(_ task: TaskEntity)
}

// MARK: - Interactor Output Protocol
protocol TasksListInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [TaskEntity])
    func didFailToFetchTasks(_ error: Error)
    func didDeleteTask()
    func didFailToDeleteTask(_ error: Error)
    func didSearchTasks(_ tasks: [TaskEntity])
    func didToggleTaskCompletion()
    func didSeedData()
}
