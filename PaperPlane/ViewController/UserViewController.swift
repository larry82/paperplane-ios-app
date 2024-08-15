import UIKit
import LineSDK
import WebKit
import AVFoundation


class UserViewController: UIViewController {
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        setupLogoutButton()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        
        if let url = URL(string: "https://flyingclub.io/dashboard/show") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func setupLogoutButton() {
        let logoutButton = UIButton(type: .system)
        logoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        logoutButton.tintColor = .white
        logoutButton.layer.cornerRadius = 15
        logoutButton.layer.shadowColor = UIColor.black.cgColor
        logoutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoutButton.layer.shadowRadius = 4
        logoutButton.layer.shadowOpacity = 0.1
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.widthAnchor.constraint(equalToConstant: 30),
            logoutButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func logoutTapped() {
        LoginManager.shared.logout { result in
            switch result {
            case .success:
                let loginViewController = LoginViewController()
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = loginViewController
                }
            case .failure(let error):
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
