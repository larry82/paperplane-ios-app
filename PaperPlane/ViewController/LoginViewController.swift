import UIKit
import LineSDK

class LoginViewController: UIViewController {
    
    private lazy var loginButton: LoginButton = {
        let button = LoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLoginButton()
        setupSkipButton()
        loginButton.delegate = self
    }
    
    private func setupLoginButton() {
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 280),
            loginButton.heightAnchor.constraint(equalToConstant: 44)  // LINE 按鈕的標準高度
        ])
        
        loginButton.contentMode = .scaleToFill
        loginButton.autoresizingMask = []
        loginButton.clipsToBounds = true
    }
    
    private func setupSkipButton() {
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skipButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func skipButtonTapped() {
        // 創建 TabBarViewController
        let tabBarController = TabBarViewController()
        
        // 將 TabBarViewController 設為根視圖控制器
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
        }
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        let accessToken = loginResult.accessToken.value
        let userID = loginResult.userProfile?.userID ?? ""
        
        // 設置全局用戶會話
        UserSession.shared.setUserInfo(accessToken: accessToken, userID: userID)
        
        // 創建 TabBarViewController
        let tabBarController = TabBarViewController()
        
        // 將 TabBarViewController 設為根視圖控制器
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: Error) {
        // 處理登錄失敗
        print("Login failed: \(error.localizedDescription)")
    }
}
