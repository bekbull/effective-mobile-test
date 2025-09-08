import Foundation
import UIKit

// MARK: - Editor Mode
enum TaskEditorMode {
    case add
    case edit(TaskEntity)
}

// MARK: - View Protocol
protocol TaskEditorViewProtocol: AnyObject {
    func setupForMode(_ mode: TaskEditorMode)
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func popView()
}

// MARK: - Presenter Protocol
protocol TaskEditorPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapBack()
    func didChange(title: String, details: String)
    func willDisappear()
}

// MARK: - Interactor Protocol
protocol TaskEditorInteractorProtocol: AnyObject {
    func createDraftIfNeeded(title: String, details: String?) -> TaskEntity
    func updateTask(_ task: TaskEntity, title: String, details: String?)
    func deleteTask(_ task: TaskEntity)
}

// MARK: - Router Protocol
protocol TaskEditorRouterProtocol: AnyObject {
    static func createModule(for mode: TaskEditorMode) -> UIViewController
    func popView()
}

// MARK: - Interactor Output Protocol
protocol TaskEditorInteractorOutputProtocol: AnyObject {
    func didSaveTask()
    func didFailToSaveTask(_ error: Error)
    func didUpdateTask()
    func didFailToUpdateTask(_ error: Error)
}
