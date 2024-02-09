//
//  Extensions+CustomClasses.swift
//  AIPainter
//
//  Created by Eduard Kanevskii on 08.02.2024.
//

import UIKit
import Lottie
import AVFoundation

final class GradientView: UIView {
    
    var startColor:   UIColor = .black { didSet { updateColors() }}
    var endColor:     UIColor = .white { didSet { updateColors() }}
    var startLocation: Double =   0.05 { didSet { updateLocations() }}
    var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

class VioletButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .violetLight : .commonGrey
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI(text: "")
    }
    
    init(text: String) {
        super.init(frame: .zero)
        setupUI(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(text: String) {
        layer.cornerRadius = 10
        
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .selected)
        titleLabel?.font = .rails(withSize: 24)
        backgroundColor = .violetLight
        
        self.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        setTitle(text, for: .normal)
        setTitle(text, for: .selected)
    }
}


extension UIColor {
    /// FF4364
    static let scarlet = UIColor(hex: "#FF4364")
    /// 30BA8F
    static let grass = UIColor(hex: "#30BA8F")
    /// #5b5b5b
    static let commonGrey = UIColor(hex: "#5b5b5b")
    /// 370258
    static let violet = UIColor(hex: "#370258")
    /// #920CE5
    static let violetLight = UIColor(hex: "#920CE5")
}

extension String {
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 1024) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? nil
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if (cString.count) != 6 {
            self.init(hex: "ffffff")
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }
    
    func addTapGesture(target: Any?, action: Selector?) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func roundOnlyTopCorners(radius: CGFloat = 20) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

extension UIStackView {
    func addArranged(subviews:[UIView]) {
        subviews.forEach { self.addArrangedSubview($0) }
    }
}


class ActivityView: UIView {
    private let animationView = LottieAnimationView()
    private let timerLabel = UILabel()
    private var estimatedTime: Int = 20
    private var countdownTimer: Timer?
    
    init(animation: LottieAnimation?, frame: CGRect, withoutAppearAnimation: Bool) {
        super.init(frame: frame)
        addSubview(animationView)
        addSubview(timerLabel)
        
        timerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(90)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
        }
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.font = .rails(withSize: 32)
        timerLabel.numberOfLines = 0
        timerLabel.text = "estimated time \(estimatedTime) sec"
        
        animationView.animation = animation
        backgroundColor = .black
        animationView.frame = self.frame
        animationView.center = center
        let window = UIApplication.shared.keyWindow ?? UIWindow()
//        let c = window.center
        self.center.y += window.center.y
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        let duration: Double = withoutAppearAnimation ? 0 : 1
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.center.y -= window.center.y
            self.transform = .identity
        }
    }
    
    func play(isInitial: Bool = false) {
        if isInitial {
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.updateLabel()
            }
            
            countdownTimer?.fire()
        }
        animationView.play { [weak self] isComplete in
            self?.play()
        }
    }
    
    func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func updateLabel() {
        estimatedTime -= 1
        if estimatedTime > 0 {
            timerLabel.text = "estimated time \(estimatedTime) sec"
        } else {
            timerLabel.text = "we need a little bit more time..."
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Animations {
        static let plane = LottieAnimation.named("plane")
    }
    
    deinit {
        stopTimer()
    }
}
extension UIViewController {
    var window: UIWindow { UIApplication.shared.keyWindow ?? UIWindow() }
    
    func showActivity(animation: LottieAnimation?, withoutAppearAnimation: Bool = false) {
        let activityView = ActivityView(animation: animation, frame: window.bounds, withoutAppearAnimation: withoutAppearAnimation)
        activityView.play(isInitial: true)
        window.addSubview(activityView)
    }
    
    func removeActivity(withoutAnimation: Bool = false, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let activity = self.window.subviews.first { $0 is ActivityView }
            let duration: TimeInterval = withoutAnimation ? 0 : 1
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                activity?.center.y += activity?.center.y ?? 0
                activity?.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            } completion: { _ in
                activity?.removeFromSuperview()
                completion?()
            }
        }
    }
}

class ErrorModal: UIView {
    private let contentView = UIView()
    private let headerLabel = FuturaLabel(text: "oooops!", fontSize: 35, numberOfLines: 1)
    private let errorLabelText = FuturaLabel(text: "", fontSize: 20)
    private let buttonsStack = VerticalStackView(spacing: 0)
    private let tryAgainButton = VioletButton(text: "try again")
    private let cancelButton = UIButton()
    private let duration: Double = 0.7
    
    var tryAgainCompletion: (()->())?
    
    private let errorText: String
    init(errorText: String) {
        self.errorText = errorText
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(contentView)
        let window = UIApplication.shared.keyWindow ?? UIWindow()
        self.center.y = window.bounds.height
        self.center.x = window.center.x
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.center.y = window.center.y
            self.transform = .identity
        } completion: { [weak self] isFinished in
            guard let self = self else { return }
            if isFinished {
                self.frame = window.frame
            }
        }
        contentView.addSubviews([headerLabel, errorLabelText, buttonsStack])
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(window.bounds.width - 50)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
        }
        
        errorLabelText.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
        }
        errorLabelText.text = errorText
        
        buttonsStack.snp.makeConstraints {
            $0.top.equalTo(errorLabelText.snp.bottom)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
            $0.bottom.equalToSuperview().offset(0)
        }
        
        buttonsStack.addArranged(subviews: [createSpacer(spacing: 12), tryAgainButton, createSpacer(spacing: 12), cancelButton, createSpacer(spacing: 20)])
        
        tryAgainButton.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
        
        cancelButton.setTitle("cancel", for: .normal)
        cancelButton.titleLabel?.font = .rails(withSize: 24)
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    private func createSpacer(spacing: Int) -> UIView {
        let v = UIView()
        v.snp.makeConstraints {
            $0.height.equalTo(spacing)
        }
        return v
    }
    
    @objc private func tryAgainTapped() {
        print("tryAgainTapped")
        let window = UIApplication.shared.keyWindow ?? UIWindow()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.center.y += window.center.y
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
        } completion: { [weak self] isFinished in
            if isFinished {
                self?.removeFromSuperview()
                self?.tryAgainCompletion?()
            }
        }
    }
    
    @objc private func cancelTapped() {
        let window = UIApplication.shared.keyWindow ?? UIWindow()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.center.y += window.center.y
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
        } completion: { [weak self] isFinished in
            if isFinished {
                self?.removeFromSuperview()
            }
        }
    }
}

class FuturaLabel: UILabel {
    init(text: String, fontSize: CGFloat, color: UIColor = .black, numberOfLines: Int = 0) {
        super.init(frame: .zero)
        self.font = .futura(withSize: fontSize)
        self.text = text
        self.textColor = color
        self.numberOfLines = numberOfLines
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
final class MessageView: UITextView {
    private let cornerRadius:  CGFloat = 5
    private let messageImageView = UIImageView()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), textContainer: nil)
        setupLayout()
        setupTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var text: String! {
        didSet {
            sizeToFit()
        }
    }
    
    var isError: Bool = true {
        didSet {
            backgroundColor = isError ? .scarlet : .grass
            messageImageView.image = isError ? UIImage(named: "idontknow") : UIImage(named: "congratz")
        }
    }
    
    private func setupLayout() {
        layer.cornerRadius = cornerRadius
        font = UIFont.systemFont(ofSize: 20, weight: .medium)
        isScrollEnabled = false
        isEditable = false
        textContainerInset.right = 40
        
        setupCloseIcon()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupTheme() {
        backgroundColor = .scarlet
        textColor = .white
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    @objc private func onTap() {
        removeFromSuperview()
    }
    
    private func setupCloseIcon() {
//        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
//        let image = UIImage(systemName: "multiply", withConfiguration: iconConfig)
        let image = UIImage(named: "idontknow")
        messageImageView.image = image
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.tintColor = .white
        
        addSubview(messageImageView)
        
        let guide = safeAreaLayoutGuide
        
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -8).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
    }
}
extension UIView {
    
    func showMessage(text: String?, onTop: Bool = false, isError: Bool = true) {
        DispatchQueue.main.async {
            guard let text = text else {
                return
            }
            
            let guide = self.safeAreaLayoutGuide
            
            let messageView = MessageView()
            messageView.isError = isError
            messageView.text = text
            messageView.alpha = 0
            
            self.addSubview(messageView)
            
            messageView.translatesAutoresizingMaskIntoConstraints = false
            messageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12).isActive = true
            messageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12).isActive = true
            
            if onTop {
                messageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10).isActive = true
            } else {
                messageView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10).isActive = true
            }
            
            UIView.animate(withDuration: 0.5) {
                messageView.alpha = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                messageView.removeFromSuperview()
            }
            
        }
    }
}

extension UIFont {
    static func futura(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Futura", size: size)!
    }
    
    static func rails(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProRailsRegular", size: size)!
    }
    
}

struct Layout {
    /// 20
    static let leading: CGFloat = 20
}

class VerticalStackView: UIStackView {
    init(distribution: UIStackView.Distribution = .fill, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) {
        super.init(frame: .zero)
        axis = .vertical
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HorizontalStackView: UIStackView {
    init(distribution: UIStackView.Distribution = .fill, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) {
        super.init(frame: .zero)
        axis = .horizontal
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    func shortVibrate() {
        AudioServicesPlaySystemSound(1519)
    }
    
    func startAvoidingKeyboard()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_onKeyboardFrameWillChangeNotificationReceived(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    func stopAvoidingKeyboard()
    {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }
    
    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification)
    {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        self.additionalSafeAreaInsets.bottom = intersection.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve)
        {
            self.view.layoutIfNeeded()
        }
    }
}
