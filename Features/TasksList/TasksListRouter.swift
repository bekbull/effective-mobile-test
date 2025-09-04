import UIKit

final class TasksListRouter {
    weak var viewController: UIViewController?
}

// MARK: - TasksListRouterProtocol
extension TasksListRouter: TasksListRouterProtocol {
    static func createModule() -> UIViewController {
        let view = TasksListViewController()
        let presenter = TasksListPresenter()
        let interactor = TasksListInteractor()
        let router = TasksListRouter()
        
        // Wire up VIPER components
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToAddTask() {
        let taskEditorVC = TaskEditorRouter.createModule(for: .add)
        let navigationController = UINavigationController(rootViewController: taskEditorVC)
        viewController?.present(navigationController, animated: true)
    }
    
    func navigateToEditTask(_ task: TaskEntity) {
        let taskEditorVC = TaskEditorRouter.createModule(for: .edit(task))
        let navigationController = UINavigationController(rootViewController: taskEditorVC)
        viewController?.present(navigationController, animated: true)
    }
}
