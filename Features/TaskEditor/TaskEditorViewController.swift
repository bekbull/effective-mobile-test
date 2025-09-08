import UIKit
import SnapKit

final class TaskEditorViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 28, weight: .bold)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.text = "Название"
        textView.textColor = .placeholderText
        return textView
    }()
    
    private lazy var detailsTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        textView.textContainer.lineFragmentPadding = 0
        textView.text = "Заметки"
        textView.textColor = .placeholderText
        textView.delegate = self
        return textView
    }()

    private lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .left
        return label
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
        titleTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.willDisappear()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextView)
        contentView.addSubview(createdAtLabel)
        contentView.addSubview(detailsTextView)
        
        view.addSubview(loadingIndicator)
        
        setupConstraints()
        
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
        
        titleTextView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        detailsTextView.snp.makeConstraints { make in
            make.top.equalTo(createdAtLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(200)
            make.bottom.equalToSuperview().offset(-20)
        }

        createdAtLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(titleTextView.snp.bottom).offset(2)
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
    @objc private func backTapped() {
        presenter.didTapBack()
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
        if textView === titleTextView && textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        } else if textView === detailsTextView && textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleTextView {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = "Название"
                textView.textColor = .placeholderText
            }
        } else if textView === detailsTextView {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = "Заметки"
                textView.textColor = .placeholderText
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let title = titleTextView.text ?? ""
        let details = detailsTextView.text ?? ""
        presenter.didChange(title: title, details: details)
    }
}

// MARK: - TaskEditorViewProtocol
extension TaskEditorViewController: TaskEditorViewProtocol {
    func setupForMode(_ mode: TaskEditorMode) {
        self.mode = mode
        
        switch mode {
        case .add:
            title = ""
            titleTextView.text = "Название"
            titleTextView.textColor = .placeholderText
            detailsTextView.text = "Заметки"
            detailsTextView.textColor = .placeholderText
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            createdAtLabel.text = formatter.string(from: Date())
            
        case .edit(let task):
            title = ""
            if let title = task.todo, !title.isEmpty {
                titleTextView.text = title
                titleTextView.textColor = .label
            }
            if let details = task.details, !details.isEmpty {
                detailsTextView.text = details
                detailsTextView.textColor = .label
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            if let createdAt = task.createdAt {
                createdAtLabel.text = formatter.string(from: createdAt)
            } else {
                createdAtLabel.text = formatter.string(from: Date())
            }
        }
        
        // Initial validation
        // No explicit save button; validation can be handled on pop if needed
    }
    
    func popView() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
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
}
