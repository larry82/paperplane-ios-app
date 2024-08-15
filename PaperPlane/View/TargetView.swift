import UIKit
import LiGScannerKit

class TargetView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    open func setupUI(){
    }
    
    open func update(device: LightID){
    }
}
