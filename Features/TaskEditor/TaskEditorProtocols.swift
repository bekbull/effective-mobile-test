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
    func showSaveButton(enabled: Bool)
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showSuccess(_ message: String)
    func dismissView()
}

// MARK: - Presenter Protocol
protocol TaskEditorPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String, details: String?)
    func didTapCancel()
    func didChangeTitleText(_ text: String)
}

// MARK: - Interactor Protocol
protocol TaskEditorInteractorProtocol: AnyObject {
    func saveTask(title: String, details: String?)
    func updateTask(_ task: TaskEntity, title: String, details: String?)
}

// MARK: - Router Protocol
protocol TaskEditorRouterProtocol: AnyObject {
    static func createModule(for mode: TaskEditorMode) -> UIViewController
    func dismissView()
}

// MARK: - Interactor Output Protocol
protocol TaskEditorInteractorOutputProtocol: AnyObject {
    func didSaveTask()
    func didFailToSaveTask(_ error: Error)
    func didUpdateTask()
    func didFailToUpdateTask(_ error: Error)
}
