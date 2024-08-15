import Foundation
import UIKit
extension ARViewController: PhotoAlbumManageable {
    
    func savePhoto(image: UIImage) {
        saveDataToAlbum(image: image)
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController (title: "", message: "已存至系統相簿", preferredStyle: .alert)
            self?.present(alertController, animated: true,completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    alertController.dismiss(animated: true)
                }
            })
        }
    }
    
    func presentSettingPage() {
        let alertController = UIAlertController (title: "沒有相簿權限", message: "前往設定頁將相簿權限打開？", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "前往設定", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                print("failed to get settingsUrl")
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}

