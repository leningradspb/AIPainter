//
//  ViewController.swift
//  AIPainter
//
//  Created by Eduard Kanevskii on 08.02.2024.
//

import UIKit
import SnapKit

final class GeneratorVC: UIViewController {
    private let gradientContentView = GradientView()
    private let messageTextView = UITextView()
    private let sendMessageButton = UIButton()
    private let placeholder = "Enter your prompt"
    private let iconConfig = UIImage.SymbolConfiguration(scale: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupGradientView()
        setupNavigationBar()
    }
    
    private func setupGradientView() {
        view.addSubview(gradientContentView)
        gradientContentView.addSubviews([messageTextView, sendMessageButton])
        gradientContentView.startLocation = 0
        gradientContentView.endLocation = 0.2
        
        gradientContentView.startColor = .violet
        gradientContentView.endColor = .black
        gradientContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        messageTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        sendMessageButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.bottom.equalTo(messageTextView.snp.bottom).offset(-5)
            $0.trailing.equalTo(messageTextView.snp.trailing).offset(-10)
        }
        
        let sendImage = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: iconConfig)
        sendMessageButton.setImage(sendImage, for: .normal)
        sendMessageButton.tintColor = .violet
        sendMessageButton.backgroundColor = .white
        sendMessageButton.layer.cornerRadius = 15
        sendMessageButton.addTarget(self, action: #selector(sendMessageTapped), for: .touchUpInside)
        
        messageTextView.delegate = self
        messageTextView.backgroundColor = .black
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 2
        messageTextView.layer.borderColor = UIColor.white.cgColor
        messageTextView.text = placeholder
        messageTextView.textColor = .white
        messageTextView.autocorrectionType = .no
        messageTextView.keyboardAppearance = .dark
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.returnKeyType = .search
        messageTextView.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 40)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }


    @objc private func sendMessageTapped() {
    }
}

extension GeneratorVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            messageTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageTextView.text = placeholder
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            sendMessageTapped()
        }
        return true
    }
}
