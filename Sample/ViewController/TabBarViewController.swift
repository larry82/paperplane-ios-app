// TabBarViewController.swift

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        customizeAppearance()
    }
    
    func setupViewControllers() {
        // 創建三個視圖控制器
        let homeURL = URL(string: "https://flyingclub.io")!
        let homeVC = WebViewViewController(url: homeURL)
        let arVC = ThemeScanViewController()
        let profileVC = UserViewController()
        
        // 設置標題和圖標
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        arVC.tabBarItem = UITabBarItem(title: "AR", image: UIImage(systemName: "camera.viewfinder"), selectedImage: UIImage(systemName: "camera.viewfinder.fill"))
        profileVC.tabBarItem = UITabBarItem(title: "Member", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        // 設置視圖控制器數組
        viewControllers = [homeVC, arVC, profileVC]
    }
    
    private func customizeAppearance() {
        // 自定义 Tab Bar 外观
        UITabBar.appearance().tintColor = .black // 选中时的颜色
        UITabBar.appearance().unselectedItemTintColor = .lightGray // 未选中时的颜色
    }
}
