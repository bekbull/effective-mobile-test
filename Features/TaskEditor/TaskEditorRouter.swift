import UIKit

final class TaskEditorRouter {
    weak var viewController: UIViewController?
}

// MARK: - TaskEditorRouterProtocol
extension TaskEditorRouter: TaskEditorRouterProtocol {
    static func createModule(for mode: TaskEditorMode) -> UIViewController {
        let view = TaskEditorViewController()
        let presenter = TaskEditorPresenter()
        let interactor = TaskEditorInteractor()
        let router = TaskEditorRouter()
        
        // Configure mode
        presenter.configure(mode: mode)
        
        // Wire up VIPER components
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func popView() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
