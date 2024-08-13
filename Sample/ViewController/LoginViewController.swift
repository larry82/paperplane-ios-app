import UIKit
import LineSDK

class LoginViewController: UIViewController {
    
    private lazy var loginButton: LoginButton = {
        let button = LoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLoginButton()
        loginButton.delegate = self
    }
    
    private func setupLoginButton() {
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
