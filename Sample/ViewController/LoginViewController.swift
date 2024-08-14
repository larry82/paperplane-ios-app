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
        view.backgroundColor = .black
        setupLoginButton()
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
        
        // 確保按鈕的內容模式正確
        loginButton.contentMode = .scaleToFill
        
        // 禁用按鈕的自動調整大小
        loginButton.autoresizingMask = []
        
        // 設置按鈕的剪裁屬性
        loginButton.clipsToBounds = true
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
