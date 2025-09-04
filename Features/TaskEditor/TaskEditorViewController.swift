import UIKit
import SnapKit

final class TaskEditorViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название задачи"
        textField.font = .systemFont(ofSize: 18, weight: .medium)
        textField.textColor = .label
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.addTarget(self, action: #selector(titleTextChanged), for: .editingChanged)
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        
        return textField
    }()
    
    private lazy var detailsTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.text = "Описание задачи..."
        textView.textColor = .placeholderText
        textView.delegate = self
        return textView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    var presenter: TaskEditorPresenterProtocol!
    private var mode: TaskEditorMode = .add
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar with modern styling
        let cancelButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        cancelButton.tintColor = .systemYellow
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        saveButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = saveButton
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(detailsTextView)
        
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        setupConstraints()
        
        // Setup keyboard handling
        setupKeyboardHandling()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        detailsTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        presenter.didTapCancel()
    }
    
    @objc private func saveTapped() {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var details = detailsTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if details is placeholder text
        if details == "Описание задачи..." || detailsTextView.textColor == .placeholderText {
            details = nil
        }
        
        let finalDetails = details?.isEmpty == true ? nil : details
        
        presenter.didTapSave(title: title, details: finalDetails)
    }
    
    @objc private func titleTextChanged() {
        let text = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        presenter.didChangeTitleText(text)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension TaskEditorViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание задачи..."
            textView.textColor = .placeholderText
        }
    }
}

// MARK: - TaskEditorViewProtocol
extension TaskEditorViewController: TaskEditorViewProtocol {
    func setupForMode(_ mode: TaskEditorMode) {
        self.mode = mode
        
        switch mode {
        case .add:
            title = "Новая задача"
            
        case .edit(let task):
            title = "Редактировать"
            titleTextField.text = task.todo
            if let details = task.details, !details.isEmpty {
                detailsTextView.text = details
                detailsTextView.textColor = .label
            }
        }
        
        // Initial validation
        titleTextChanged()
    }
    
    func showSaveButton(enabled: Bool) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = enabled
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func showSuccess(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismissView()
            })
            self.present(alert, animated: true)
        }
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
