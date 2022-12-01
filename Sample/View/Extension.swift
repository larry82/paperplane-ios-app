import Foundation
import UIKit

extension UIButton{
    func setShadow(){
        if let label = titleLabel{
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = CGSize(width: 0, height: 1)
            label.layer.shadowOpacity = 0.3
            label.layer.shadowRadius = 2
            label.layer.masksToBounds = false
        }
    }
}
