//
//  ViewController.swift
//  AIPainter
//
//  Created by Eduard Kanevskii on 08.02.2024.
//

import UIKit
import SnapKit

final class EnterTextViewController: UIViewController {
    private let gradientContentView = GradientView()
    private let messageTextView = UITextView()
    private let sendMessageButton = UIButton()
    private let placeholder = "Enter your prompt"
    
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
        gradientContentView.startLocation = 0
        gradientContentView.endLocation = 0.2
        
        gradientContentView.startColor = .violet
        gradientContentView.endColor = .black
        gradientContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }


}

