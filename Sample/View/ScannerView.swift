import UIKit
import LiGScannerKit

class ScannerView: UIView {
    var targetView: TargetView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    open func setupUI(){
        if let targetView = targetView {
            addSubview(targetView)
            targetView.frame.origin = CGPoint(x: 0, y: 0)
            targetView.isHidden = true
        }
    }
    
    open func update(device: LightID){
        DispatchQueue.main.async {
            guard let targetView = self.targetView else { return }
            let windowWidth = Float(self.frame.width)
            let windowHeight = Float(self.frame.height.native)
            let aimPosX = CGFloat(windowWidth * device.coordinateX)
            let aimPosY = CGFloat(windowHeight * device.coordinateY)
            
            targetView.isHidden = false
            targetView.update(device: device)
            targetView.center.x = aimPosX
            targetView.center.y = aimPosY
        }
    }
}
