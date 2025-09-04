import UIKit
import SnapKit

final class TasksListViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.searchTextField.backgroundColor = .tertiarySystemBackground
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.textColor = .label
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет задач.\nНажмите + чтобы добавить первую задачу!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private lazy var bottomTopSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addTaskButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "square.and.pencil")
        config.baseForegroundColor = .systemYellow
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        button.configuration = config
        button.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    var presenter: TasksListPresenterProtocol!
    private var tasks: [TaskEntity] = []
    private var isSearching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad() // Refresh data when returning from other screens
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Задачи"
        
        // Setup navigation bar with modern styling
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Setup table view
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(bottomContainerView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)
        
        bottomContainerView.addSubview(taskCountLabel)
        bottomContainerView.addSubview(addTaskButton)
        bottomContainerView.addSubview(bottomTopSeparator)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainerView.snp.top)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(110)
        }
        
        taskCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }

        bottomTopSeparator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        
        addTaskButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(taskCountLabel.snp.centerY)
            make.width.height.equalTo(36)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func addTaskTapped() {
        presenter.didTapAddTask()
    }
}

// MARK: - TasksListViewProtocol
extension TasksListViewController: TasksListViewProtocol {
    func showTasks(_ tasks: [TaskEntity]) {
        self.tasks = tasks
        self.isSearching = false
        DispatchQueue.main.async {
            self.emptyStateLabel.isHidden = !tasks.isEmpty
            self.updateTaskCounter()
            self.tableView.reloadData()
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.emptyStateLabel.isHidden = true
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func showSearchResults(_ tasks: [TaskEntity]) {
        self.tasks = tasks
        self.isSearching = true
        DispatchQueue.main.async {
            self.emptyStateLabel.isHidden = !tasks.isEmpty
            self.updateTaskCounter()
            self.tableView.reloadData()
        }
    }
    
    private func updateTaskCounter() {
        let totalTasks = tasks.count
        let completedTasks = tasks.filter { $0.completed }.count
        
        if totalTasks == 0 {
            taskCountLabel.text = "Нет задач"
        } else if totalTasks == 1 {
            taskCountLabel.text = "1 Задача"
        } else if totalTasks < 5 {
            taskCountLabel.text = "\(totalTasks) Задачи"
        } else {
            taskCountLabel.text = "\(totalTasks) Задач"
        }
    }
}

// MARK: - UITableViewDataSource
extension TasksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        let task = tasks[indexPath.row]
        
        cell.delegate = self
        cell.configure(with: task)
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.setSeparatorHidden(isLast)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // No action on tap; long-press shows context menu
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, completion in
            self?.confirmDeleteTask(task)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let toggleAction = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completion in
            self?.presenter.didToggleTaskCompletion(task)
            completion(true)
        }
        toggleAction.image = UIImage(systemName: task.completed ? "arrow.counterclockwise" : "checkmark")
        toggleAction.backgroundColor = task.completed ? .systemOrange : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }

    // Context menu on long press (iOS 13+)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.presenter.didTapEditTask(task)
            }
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareTask(task)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.confirmDeleteTask(task)
            }
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
    
    // MARK: - Action Sheet
    private func showTaskActionSheet(for task: TaskEntity) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Edit action
        let editAction = UIAlertAction(title: "Редактировать", style: .default) { [weak self] _ in
            self?.presenter.didTapEditTask(task)
        }
        editAction.setValue(UIImage(systemName: "pencil"), forKey: "image")
        
        // Share action
        let shareAction = UIAlertAction(title: "Поделиться", style: .default) { [weak self] _ in
            self?.shareTask(task)
        }
        shareAction.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")
        
        // Delete action
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.confirmDeleteTask(task)
        }
        deleteAction.setValue(UIImage(systemName: "trash"), forKey: "image")
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(shareAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
    
    private func shareTask(_ task: TaskEntity) {
        var shareText = task.todo ?? "Task"
        if let details = task.details, !details.isEmpty {
            shareText += "\n\n\(details)"
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    private func confirmDeleteTask(_ task: TaskEntity) {
        let alert = UIAlertController(
            title: "Удалить задачу?",
            message: "Это действие нельзя отменить.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.presenter.didTapDeleteTask(task)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - TaskTableViewCellDelegate
extension TasksListViewController: TaskTableViewCellDelegate {
    func taskCell(_ cell: TaskTableViewCell, didToggleFor task: TaskEntity) {
        presenter.didToggleTaskCompletion(task)
    }
}

// MARK: - UISearchBarDelegate
extension TasksListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            presenter.didClearSearch()
        } else {
            presenter.didSearchTasks(query: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter.didClearSearch()
    }
}
