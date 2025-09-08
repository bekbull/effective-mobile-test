import UIKit
import SnapKit

final class TaskTableViewCell: UITableViewCell {
    weak var delegate: TaskTableViewCellDelegate?
    private var currentTask: TaskEntity?
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private var titleLeadingWithIcon: Constraint?
    private var titleLeadingWithoutIcon: Constraint?
    
    // MARK: - UI Components
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 3
        return view
    }()
    
    private lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset visual state so reused cells don't inherit styles
        titleLabel.attributedText = nil
        titleLabel.textColor = .label
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.isHidden = false
        dateLabel.textColor = .tertiaryLabel
        statusImageView.image = UIImage(systemName: "circle")
        statusImageView.tintColor = .systemGray3
        statusImageView.isHidden = false
        statusImageView.alpha = 1
        // Restore default constraints: date below details
        dateLabel.snp.remakeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(detailsLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        separatorView.isHidden = false
        separatorView.alpha = 1
        // Default: show icon and use with-icon leading
        titleLeadingWithoutIcon?.deactivate()
        titleLeadingWithIcon?.activate()
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Add subviews
        contentView.addSubview(cardView)
        cardView.addSubview(statusImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(detailsLabel)
        cardView.addSubview(dateLabel)
        contentView.addSubview(separatorView)
        
        // Tap gesture on status icon
        statusImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapStatus))
        statusImageView.addGestureRecognizer(tap)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview()
        }
        
        statusImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            titleLeadingWithIcon = make.leading.equalTo(statusImageView.snp.trailing).offset(12).constraint
            titleLeadingWithoutIcon = make.leading.equalToSuperview().offset(16).constraint
            titleLeadingWithoutIcon?.deactivate()
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        detailsLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(detailsLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // Custom thick separator at bottom (2px device-aware)
        separatorView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(2.0 / UIScreen.main.scale)
        }
    }
    
    // MARK: - Configuration
    func configure(with task: TaskEntity) {
        currentTask = task
        // Ensure default layout state for fresh cells (not yet reused)
        titleLeadingWithoutIcon?.deactivate()
        titleLeadingWithIcon?.activate()
        statusImageView.isHidden = false
        statusImageView.alpha = 1
        separatorView.isHidden = false
        separatorView.alpha = 1
        titleLabel.text = task.todo
        
        if let details = task.details, !details.isEmpty {
            detailsLabel.text = details
            detailsLabel.isHidden = false
            // Ensure date is placed below details when details exist
            dateLabel.snp.remakeConstraints { make in
                make.leading.equalTo(titleLabel)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalTo(detailsLabel.snp.bottom).offset(8)
                make.bottom.equalToSuperview().offset(-16)
            }
        } else {
            detailsLabel.isHidden = true
            dateLabel.snp.remakeConstraints { make in
                make.leading.equalTo(titleLabel)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.bottom.equalToSuperview().offset(-16)
            }
        }
        
        if let createdAt = task.createdAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            dateLabel.text = formatter.string(from: createdAt)
        } else {
            dateLabel.text = ""
        }
        
        // Update completion status
        if task.completed {
            // Yellow ring with checkmark
            statusImageView.image = UIImage(systemName: "checkmark.circle")
            statusImageView.tintColor = .systemYellow
            titleLabel.textColor = .secondaryLabel
            detailsLabel.textColor = .tertiaryLabel
            
            // Add strikethrough effect
            if let text = titleLabel.text {
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
                titleLabel.attributedText = attributedString
            }
        } else {
            // Gray ring, center appears black on dark background
            statusImageView.image = UIImage(systemName: "circle")
            statusImageView.tintColor = .systemGray3
            titleLabel.textColor = .label
            detailsLabel.textColor = .secondaryLabel
            titleLabel.attributedText = nil
            titleLabel.text = task.todo
        }
    }

    @objc private func didTapStatus() {
        guard let task = currentTask else { return }
        delegate?.taskCell(self, didToggleFor: task)
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        separatorView.isHidden = hidden
    }
    
    func setStatusIconHiddenAndShift(_ hidden: Bool) {
        // Prepare for animation
        if !hidden {
            statusImageView.isHidden = false
            separatorView.isHidden = false
        }
        if hidden {
            titleLeadingWithIcon?.deactivate()
            titleLeadingWithoutIcon?.activate()
        } else {
            titleLeadingWithoutIcon?.deactivate()
            titleLeadingWithIcon?.activate()
        }
        setNeedsLayout()
        UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.4, options: [.curveEaseInOut]) {
            self.statusImageView.alpha = hidden ? 0 : 1
            self.separatorView.alpha = hidden ? 0 : 1
            self.cardView.layoutIfNeeded()
        } completion: { _ in
            self.statusImageView.isHidden = hidden
            self.separatorView.isHidden = hidden
        }
    }
}

protocol TaskTableViewCellDelegate: AnyObject {
    func taskCell(_ cell: TaskTableViewCell, didToggleFor task: TaskEntity)
}
