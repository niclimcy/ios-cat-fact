//
//  ViewController.swift
//  Cat Fact
//
//  Created by Nicholas Lim on 22/10/26.
//

import UIKit

class ViewController: UIViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let catFactLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 8
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .tertiaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 28,
            weight: .medium
        )
        imageView.image = UIImage(systemName: "cat")
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false

        return indicator
    }()

    private let catButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.prominentGlass()
        config.title = "Get new cat"
        config.image = UIImage(systemName: "sparkles")
        config.imagePadding = 8
        button.configuration = config

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(catFactLabel)
        stackView.addArrangedSubview(catButton)
        imageView.addSubview(activityIndicator)

        // MARK: - Get new cat button
        catButton.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self else { return }
                catButtonTapped()
            }),
            for: .touchUpInside
        )
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 24
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -24
            ),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            activityIndicator.centerXAnchor.constraint(
                equalTo: imageView.centerXAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: imageView.centerYAnchor
            ),
        ])
    }

    private func catButtonTapped() {
        struct CatFact: Codable {
            var fact: String
            var length: Int
        }

        Task {
            activityIndicator.startAnimating()
            catButton.isEnabled = false

            if let cataasURL = URL(string: "https://cataas.com/cat") {
                let (data, _) = try await URLSession.shared.data(
                    from: cataasURL
                )
                imageView.contentMode = .scaleAspectFill
                imageView.image = UIImage(data: data)
            }
            
            if let apiURL = URL(string: "https://catfact.ninja/fact") {
                let (data, _) = try await URLSession.shared.data(from: apiURL)
                let catFact = try JSONDecoder().decode(CatFact.self, from: data)
                catFactLabel.text = catFact.fact
            }

            activityIndicator.stopAnimating()
            catButton.isEnabled = true
        }
    }
}

#Preview {
    ViewController()
}
